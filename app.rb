require 'rack-flash'
require 'json'
require_relative 'models/model'
require_relative 'models/user'
require_relative 'models/document'
require_relative 'models/document_user'
require_relative 'models/page'
require_relative 'models/helpers'

class App < Sinatra::Base
    
    enable :sessions
    use Rack::Flash

    # Get the currently logged in user.
    #
    # @see User.get
    before('/') do
        if session[:user_id]
            @current_user = User.get({user_id: session[:user_id]})
        else
            @current_user = User.get({username: "GuestUser"})
        end
    end

    # Get the main page, the index.slim.
    #
    # @see Document.all
    # @see Document#allowed_users
    # @see DocumentUser.all
    get('/') do
        @docs = Document.all({})

        @docs.map do |doc|
            doc.allowed_users(DocumentUser.all({document_id: doc.document_id}).map{ |user| user.user_id })
        end

        slim(:'components/index')
    end

    # The about page.
    get('/about') do
        slim(:'components/about')
    end

    # The license page.
    get('/license') do
        slim(:'components/license')
    end
    
    # The page of where you sign up a new user.
    get('/signup') do
        slim(:'components/signup')
    end

    # Signs up a new user if email and username does not already exist.
    #
    # @param username[String] The username of the wanted user.
    # @param email [String] The email of the wanted user.
    # @param password [String] The password of the wanted user.
    # @param first_name [String] The first name of the wanted user.
    # @param last_name [String] The last name of the wanted user.
    # @param profile_pic [Object] The profile picture of the wanted user.
    #
    # @see User.all
    # @see User.validate_email
    # @see User.hash_password
    # @see User.create
    # @see Helpers.store_pic
    post('/signup') do
        user = User.all({username: params['username'], email: params['email']}, "", "OR")
        if user.map{|usr| usr.username == params['username']}.any?()
            flash[:errors] = {signup: "This username is already in use."}
            redirect(back)
        elsif user.map{|usr| usr.email == params['email']}.any?()
            flash[:errors] = {signup: "This email is already in use."}
            redirect(back)
        end
        if not User.validate_email(params['email'])
            flash[:errors] = {signup: "Please provide a valid email address."}
            redirect(back)
        end

        hashed_password = User.hash_password(params['password'])
        profile_pic = Helpers.store_pic(params['profile_pic'])

        session[:user_id] = User.create({first_name: params['first_name'], last_name: params['last_name'], email: params['email'], username: params['username'], password: hashed_password, profile_pic: profile_pic})
        flash[:success] = {signup: "Registration successful"}

        redirect('/')
    end

    # The page of where you login onto an already existing user.
    get('/login') do
        slim(:'components/login')
    end

    # Logs in to an already existing user if authorized.
    #
    # @param username [String] The username of the user.
    # @param password [String] The password of the user.
    #
    # @see User.get
    # @see User#authorize
    post('/login') do
        user = User.get({username: params['username']})

        if user and user.authorize(params['password'])
            session[:user_id] = user.user_id
            redirect('/')
        else
            flash[:errors] = {login: "Username or password is invalid"}
            redirect(back)
        end
    end

    # Logout from an user.
    post('/logout') do
        session[:user_id] = nil

        redirect(back)
    end

    # Get a user's profile page.
    #
    # @param :id [Integer] The ID of the user.
    #
    # @see User.get
    # @see Document.all
    # @see Document#allowed_users
    # @see DocumentUser.all
    get('/profile/:id') do
        @user = User.get({user_id: params['id'].to_i})
        if not @user
            redirect('/')
        end
        @docs = Document.all({user_id: params['id'].to_i}) { {join: User, through: DocumentUser} }

        @docs.map do |doc|
            doc.allowed_users(DocumentUser.all({document_id: doc.document_id}).map{ |user| user.user_id })
        end

        slim(:'components/user')
    end

    # Let's an user make a post.
    #
    # @param title [String] The post's title.
    # @param post_pic [Object] The picture of the post to be created.
    # @param guests [String] The list of guests' usernames that you want to share the
    # document with. Separate guests by spaces or commas.
    #
    # @see User#logged_in?
    # @see Document.create
    # @see Helpers.store_pic
    # @see User.get
    # @see DocumentUser.create
    post('/document/create') do
        if @current_user.logged_in?()
            document_id = Document.create({title: params['title'], user_id: @current_user.user_id, preview: Helpers.store_pic(params['post_pic'])})

            params['guests'].split(/([\s,]+)/).each do |guest|
                user = User.get({username: guest})
                if user
                    DocumentUser.create({user_id: user.user_id, document_id: document_id})
                end
            end
        end
        redirect('/')
    end
    
    # Deletes a post.
    #
    # param :document_id [Integer] The document's ID of which post to delete.
    #
    # @see User#logged_in?
    # @see DocumentUser.all
    # @see Document.get
    # @see Document.delete
    post('/document/delete/:document_id') do
        if @current_user.logged_in?()
            allowed_users = DocumentUser.all({document_id: params['document_id'].to_i}).any? { |doc_user| doc_user.user_id == session[:user_id] }

            if allowed_users
                document = Document.get({document_id: params['document_id'].to_i})
                if not document.preview.nil?()
                    FileUtils.remove_file("./public/img/#{document.preview}")
                end
                Document.delete({document_id: params['document_id'].to_i})
            end
        end
        redirect(back)
    end

    # Validate if user can open a document.
    #
    # param :document_id [Integer] The ID of the document.
    #
    # @see User#logged_in?
    # @see DocumentUser.all
    # @see Document.get
    post('/document/:document_id') do
        if @current_user.logged_in?()
            allowed_users = DocumentUser.all({document_id: @doc.document_id}).any? { |doc_user| doc_user.user_id == session[:user_id] }

            if allowed_users
                @doc = Document.get({document_id: params['document_id'].to_i})

                redirect("/document/#{params["document_id"]}")
            end
        else
            redirect('/')
        end
    end

    # Open a document.
    #
    # param :id [Integer] The ID of the document.
    #
    # @see User#logged_in?
    # @see DocumentUser.all
    # @see Document.get
    # @see Page.all
    get('/document/:id') do
        if @current_user.logged_in?()
            allowed_users = DocumentUser.all({document_id: @doc.document_id}).any? { |doc_user| doc_user.user_id == session[:user_id] }

            if allowed_users
                @doc = Document.get({document_id: params['id'].to_i})

                if @doc and             
                    @pages = Page.all({document_id: @doc.document_id})

                    slim(:'components/document')
                end
            end
        else
            redirect('/')
        end
    end

    # Saves a specified page on a document.
    #
    # param :document_id [Integer] The ID of the document.
    # param :page_number [Integer] The page number.
    #
    # @see User#logged_in?
    # @see DocumentUser.all
    # @see Page.get
    # @see Page.update
    # @see Page.create
    post('/save/:document_id/:page_number') do
        if @current_user.logged_in?()
            allowed_users = DocumentUser.all({document_id: @doc.document_id}).any? { |doc_user| doc_user.user_id == session[:user_id] }

            if allowed_users
                page = Page.get({page_number: params['page_number'].to_i, document_id: params['document_id'].to_i})
                
                change = JSON.parse(request.body.read, symbolize_names: true)

                if page
                    Page.update({text_content: change[:text_content] }, { document_id: params['document_id'].to_i, page_number: params['page_number'].to_i})
                else
                    Page.create({text_content: change[:text_content], document_id: params['document_id'].to_i, page_number: params['page_number'].to_i})
                end
            end
        end
    end

    # Delete a page on a specified document.
    #
    # param :document_id [Integer] The ID of the document.
    # param :page_number [Integer] The page number.
    #
    # @see User#logged_in?
    # @see DocumentUser.all
    # @see Page.delete
    post('/page/delete/:document_id/:page_number') do
        if @current_user.logged_in?()
            allowed_users = DocumentUser.all({document_id: @doc.document_id}).any? { |doc_user| doc_user.user_id == session[:user_id] }

            if allowed_users
                Page.delete({page_number: params['page_number'].to_i, document_id: params['document_id'].to_i})
            end
        end
    end
end
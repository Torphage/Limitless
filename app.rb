require 'rack-flash'
require 'json'
require_relative 'models/model'
require_relative 'models/user'
require_relative 'models/document'
require_relative 'models/document_user'
require_relative 'models/page'

class App < Sinatra::Base
    
    enable :sessions
    use Rack::Flash

    helpers() do 
        def store_pic(pic)
            if pic.nil?
                return nil
            else
                file_name = SecureRandom.uuid
                FileUtils.copy(pic['tempfile'], "./public/img/#{file_name}")
                return file_name
            end
        end
    end

    before() do
        if session[:user_id]
            @current_user = User.get({user_id: session[:user_id]})
        else
            @current_user = User.get({username: "GuestUser"})
        end
    end

    get('/') do
        @docs = Document.all({})

        @docs.map do |doc|
            doc.allowed_users(DocumentUser.all({document_id: doc.document_id}).map{ |user| user.user_id })
        end

        slim(:'components/index')
    end

    get('/about') do
        slim(:'components/about')
    end

    get('/license') do
        slim(:'components/license')
    end
    
    get('/signup') do
        slim(:'components/signup')
    end
    
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
        profile_pic = store_pic(params['profile_pic'])

        session[:user_id] = User.create({first_name: params['first_name'], last_name: params['last_name'], email: params['email'], username: params['username'], password: hashed_password, profile_pic: profile_pic})
        flash[:success] = {signup: "Registration successful"}

        redirect('/')
    end

    get('/login') do
        slim(:'components/login')
    end

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

    post('/logout') do
        session[:user_id] = nil

        redirect(back)
    end

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

    post('/document/create') do
        if @current_user.logged_in?()
            document_id = Document.create({title: params['title'], user_id: @current_user.user_id, preview: store_pic(params['post_pic'])})

            params['guests'].split(/([\s,]+)/).each do |guest|
                user = User.get({username: guest})
                if user
                    DocumentUser.create({user_id: user.user_id, document_id: document_id})
                end
            end
        end
        redirect('/')
    end
    
    post('/document/delete/:document_id') do
        if @current_user.logged_in?()
            document = Document.get({document_id: params['document_id'].to_i})
            if not document.preview.nil?()
                FileUtils.remove_file("./public/img/#{document.preview}")
            end
            Document.delete({document_id: params['document_id'].to_i})
        end
        redirect(back)
    end

    post('/document/:document_id') do
        @doc = Document.get({document_id: params['document_id'].to_i})

        @doc.allowed_users(DocumentUser.all({document_id: @doc.document_id}).map{ |user| user.user_id })

        if @doc.get_allowed_users().include?(@current_user.user_id)
            redirect("/document/#{params["document_id"]}")
        else
            redirect('/')
        end
    end

    get('/document/:id') do
        @doc = Document.get({document_id: params['id'].to_i})

        if @doc and @current_user.logged_in?()            
            @pages = Page.all({document_id: @doc.document_id})

            slim(:'components/document')
        else
            redirect('/')
        end
    end

    post('/save/:document_id/:page_number') do
        if @current_user.logged_in?()    
            page = Page.get({page_number: params['page_number'].to_i, document_id: params['document_id'].to_i})
            
            change = JSON.parse(request.body.read, symbolize_names: true)

            if page
                Page.update({text_content: change[:text_content] }, { document_id: params['document_id'].to_i, page_number: params['page_number'].to_i})
            else
                Page.create({text_content: change[:text_content], document_id: params['document_id'].to_i, page_number: params['page_number'].to_i})
            end
        end
    end

    post('/page/delete/:document_id/:page_number') do
        if @current_user.logged_in?()
            Page.delete({page_number: params['page_number'].to_i, document_id: params['document_id'].to_i})
        end
    end
end
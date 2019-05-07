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
            @current_user = User.get({id: session[:user_id]})
        else
            @current_user = User.get({username: "GuestUser"})
        end
    end

    get('/') do
        @docs = Document.all({})

        @docs.map do |doc|
            doc.allowed_users(DocumentUser.all({documentId: doc.id}).map{ |temp| temp.userId })
        end

        slim(:'components/index')
    end

    get('/about') do
        slim(:'components/about')
    end
    
    get('/signup') do
        slim(:'components/signup')
    end
    
    post('/signup') do
        if User.get({username: params['username']})
            redirect(back)
        elsif User.get({email: params['email']})
            redirect(back)
        elsif not User.validate_email(params['email'])
            redirect(back)
        end

        hashed_password = User.hash_password(params['password'])
        profile_pic = store_pic(params['profile_pic'])
        session[:user_id] = User.create({firstName: params['first_name'], lastName: params['last_name'], email: params['email'], username: params['username'], password: hashed_password, profilePic: profile_pic})

        redirect('/')
    end

    get('/login') do
        slim(:'components/login')
    end

    post('/login') do
        user = User.get({username: params['username']})

        if user and user.authorize(params['password'])
            session[:user_id] = user.id
            redirect('/')
        else
            redirect(back)
        end
    end

    post('/logout') do
        session[:user_id] = nil

        redirect(back)
    end

    get('/profile/:id') do
        @user = User.get({id: params['id'].to_i})
        @docs = Document.all({id: params['id'].to_i}) { {join: User, through: DocumentUser} }

        @docs.map do |doc|
            doc.allowed_users(DocumentUser.all({documentId: doc.id}).map{ |temp| temp.userId })
        end

        slim(:'components/user')
    end

    post('/document/create') do
        if @current_user.logged_in?()
            document_id = Document.create({title: params['title'], owner: @current_user.id, preview: store_pic(params['post_pic'])})
            Page.create({documentId: document_id, textContent: "", pageInt: 1})
            DocumentUser.create({userId: @current_user.id, documentId: document_id})

            p params['guests'].split(/([\s,]*)/)
            params['guests'].split(/([\s,]*)/).each do |guest|
                p guest
                guestId = User.get({username: guest})
                if guestId
                    DocumentUser.create({userId: guestId, documentId: document_id})
                end
            end
        end
        redirect('/')
    end

    post('/document/:id') do
        @doc = Document.get({id: params['id'].to_i})

        @doc.allowed_users(DocumentUser.all({documentId: @doc.id}).map{ |temp| temp.userId })

        if @doc.get_allowed_users().include?(@current_user.id)
            redirect("/document/#{params["id"]}")
        else
            redirect('/')
        end
    end

    get('/document/:id') do
        if @current_user.logged_in?()            
            @docId = params['id'].to_i
            @pages = Page.all({documentId: @docId})

            slim(:'components/document')
        else
            redirect('/')
        end
    end

    post('/save/:docId/:pageId') do
        if @current_user.logged_in?()    
            page = Page.get({pageInt: params['pageId'].to_i, documentId: params['docId']})
            
            change = JSON.parse(request.body.read, symbolize_names: true)

            if page
                Page.update({ textContent: change[:textContent] }, { documentId: params['docId'].to_i, pageInt: params['pageId'].to_i })
            else
                Page.create({documentId: params['docId'].to_i, pageInt: params['pageId'].to_i, textContent: change[:textContent]})
            end
        end
    end

    post('/page/delete/:docId/:pageId') do
        if @current_user.logged_in?()
            Page.delete({pageInt: params['pageId'].to_i, documentId: params['docId'].to_i})
        end
    end
end
require 'rack-flash'
require 'json'
require_relative 'models/model'
require_relative 'models/user'
require_relative 'models/document'
require_relative 'models/page'

class App < Sinatra::Base
    
    enable :sessions
    use Rack::Flash

    before() do
        if session[:user_id]
            @current_user = User.get("id", session[:user_id])
        else
            @current_user = User.new()
        end
    end

    get('/') do
        @docs = Document.all()

        slim(:'components/index')
    end

    get('/about') do
        slim(:'components/about')
    end
    
    get('/signup') do
        slim(:'components/signup')
    end
    
    post('/signup') do
        if @current_user.signup(params)
            flash[:errors] = @current_user.errors
            session[:user_id] = @current_user.data[:id]

            redirect('/')
        else
            flash[:errors] = @current_user.errors

            redirect(back)
        end
    end

    get('/login') do
        slim(:'components/login')
    end

    post('/login') do
        if @current_user.authenticate(params)
            flash[:errors] = @current_user.errors
            session[:user_id] = @current_user.data[:id]

            redirect('/')
        else
            flash[:errors] = @current_user.errors

            redirect(back)
        end
    end

    post('/logout') do
        @current_user.logout()
        session[:user_id] = nil

        redirect(back)
    end

    get('/profile/:id') do
        @docs = Document.all()
        @user = User.get("id", params['id'])

        slim(:'components/user')
    end

    post('/document/create') do
        @current_user.create_document(params)

        redirect('/')
    end

    post('/document/:id') do
        @doc = Document.get("id", params['id'])

        if @current_user.data == nil
            redirect('/')
        else
            if @doc.data[:users].include?(@current_user.data[:id].to_s)
                redirect('/')
            else
                redirect("/document/#{params["id"]}")
            end
        end
    end

    get('/document/:id') do
        @doc = Document.get("id", params['id'].to_i)

        slim(:'components/document')
    end

    post('/save/:id') do
        @doc = Document.get("id", params['id'].to_i)

        change = JSON.parse(request.body.read, symbolize_names: true)

        @doc = @doc.save(change)
    end

    post('/page/delete/:id') do
        @doc = Document.get("id", params['id'].to_i)

        @doc = @doc.deletePage(params['pageInt'])
    end
end
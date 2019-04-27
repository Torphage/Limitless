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
            @current_user = User.get(session[:user_id])
        else
            @current_user = User.new()
        end
    end

    get('/') do
        db = SQLite3::Database.open('db/data.db')
        db.results_as_hash = true
        @docs = db.execute('SELECT * FROM documents')
        # p @docs
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
        db = SQLite3::Database.open('db/data.db')
        db.results_as_hash = true
        @docs = db.execute('SELECT * FROM documents')
        @user = User.get(params['id'])

        slim(:'components/user')
    end

    get('/document/:id') do
        @doc = Document.get(params['id'])

        if @current_user.data == nil
            slim(:'components/index')
        else
            if @doc.data[:users].include?(@current_user.data[:id].to_s)
                slim(:'components/document')
            else
                slim(:'components/index')
            end
        end
    end

    post('/save/:id') do
        @doc = Document.get(params['id'])

        change = JSON.parse(request.body.read, symbolize_names: true)

        @doc = @doc.save(params, change)
    end

    post('/page/delete/:id') do
        @doc = Document.get(params['id'])

        @doc = @doc.deletePage(params['pageInt'])
    end
end
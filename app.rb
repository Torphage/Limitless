require 'rack-flash'
require_relative 'models/user'
require_relative 'models/document'

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

        p @doc
        slim(:'components/document')
    end

    post('/save/:id') do
        @doc = Document.get(params['id'])
        @doc.save(params)

        p "saved!!!!"
        redirect(back)
    end
end
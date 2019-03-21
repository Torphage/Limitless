require 'rack-flash'
require_relative 'models/user'

class App < Sinatra::Base

    enable :sessions
    use Rack::Flash

    before() do
        if session[:user_id]
            @user = User.get(session[:user_id])
        else
            @user = User.new()
        end
    end

    get('/') do
        db = SQLite3::Database.open('db/data.db')
        db.results_as_hash = true
        @docs = db.execute('SELECT * FROM documents')
        p @docs
        slim(:'components/index')
    end

    get('/about') do
        slim(:'components/about')
    end
    
    get('/signup') do
        slim(:'components/signup')
    end
    
    post('/signup') do
        if @user.signup(params)
            flash[:errors] = @user.errors
            session[:user_id] = @user.data[:id]

            redirect('/')
        else
            flash[:errors] = @user.errors

            redirect(back)
        end
    end

    get('/login') do
        slim(:'components/login')
    end

    post('/login') do
        if @user.authenticate(params)
            flash[:errors] = @user.errors
            session[:user_id] = @user.data[:id]

            redirect('/')
        else
            flash[:errors] = @user.errors

            redirect(back)
        end
    end

    post('/logout') do
        @user.logout()
        session[:user_id] = nil

        redirect(back)
    end
end
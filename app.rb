require 'rack-flash'
require_relative 'models/user'

class App < Sinatra::Base

    enable :sessions
    use Rack::Flash

    before() do
        p session
        if session[:user_id]
            @user = User.get(session[:user_id])
        else
            @user = User.new()
        end
        p @user
        # p @user.data
    end

    get('/') do
        db = SQLite3::Database.open('db/data.db')
        # User.all()
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
            session[:user_id] = @user.data[:id]
            redirect('/')
        else
            redirect('/signup')
        end
    end

    get('/login') do
        slim(:'components/login')
    end

    post('/login') do
        if @user.authenticate(params)
            p @user
            session[:user_id] = @user.data[:id]
            redirect('/')
        else
            redirect('/login')
        end
    end

    post('/logout') do
        @user.logout()
        session[:user_id] = nil
        redirect(back)
    end
end
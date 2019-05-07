class User < Model
    attr_reader :errors, :success
    
    table 'users'
    
    column 'user_id', 'INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'
    column 'first_name', 'VARCHAR(255) NOT NULL'
    column 'last_name', 'VARCHAR(255) NOT NULL'
    column 'email', 'VARCHAR(255) NOT NULL UNIQUE'
    column 'username', 'VARCHAR(255) NOT NULL UNIQUE'
    column 'password', 'VARCHAR(255) NOT NULL'
    column 'profile_pic', 'VARCHAR(255)'

    def initialize(dict)
        super(dict)
        @errors = {}
        @success = ""
    end

    def authorize(guessed_password)
        return ((not @user_id.nil?()) and (BCrypt::Password.new(@password) == guessed_password))
    end    

    def logged_in?()
        @username != "GuestUser" ? true : false
    end

    def self.validate_email(email)
        email_validation_regex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

        if (email =~ email_validation_regex).nil?()
            return false
        else
            return true
        end
    end

    def self.hash_password(password)
        hashed_password = BCrypt::Password.create(password)
    end
end
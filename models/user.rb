class User < Model
    attr_reader :errors, :success
    
    table_name 'users'
    
    column 'id', 'INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'
    column 'firstName', 'VARCHAR(255) NOT NULL'
    column 'lastName', 'VARCHAR(255) NOT NULL'
    column 'email', 'VARCHAR(255) NOT NULL UNIQUE'
    column 'username', 'VARCHAR(255) NOT NULL UNIQUE'
    column 'password', 'VARCHAR(255) NOT NULL'
    column 'profilePic', 'VARCHAR(255)'

    def initialize(dict)
        super(dict)
        @errors = {}
        @success = ""
    end

    def authorize(guessed_password)
        return ((not @id.nil?()) and (BCrypt::Password.new(@password) == guessed_password))
    end    

    def logged_in?()
        @username != "GuestUser" ? true : false
    end

    def self.validate_email(email)
        email_validation_regex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

        if (email =~ email_validation_regex).nil?()
            @errors[:signup] = 'Email is not correct, please use a valid email address'
            return false
        else
            return true
        end
    end

    def self.hash_password(password)
        hashed_password = BCrypt::Password.create(password)
    end
end
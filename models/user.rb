class User
    attr_reader :data, :errors, :success
    
    def initialize()
        @data = nil
        @errors = {}
        @success = ""
    end

    def store_data(db_array)
        @data = {
            id: 		 db_array[0],
            first_name:	 db_array[1],
            last_name:	 db_array[2],
            email: 		 db_array[3],
            username:	 db_array[4],
            password:	 db_array[5],
            profile_pic: db_array[6]
        }
    end

    def get_flash()
        return @errors
    end
    
    def authenticate(params)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        user = db.execute('SELECT id, password FROM users WHERE username=?', [params['username']])

        if user.empty?()
            @errors[:login] = 'Failed do login, user does not exist'
            return false
        end
        
        if BCrypt::Password.new(user[0]['password']) == params['password']
            result = db.execute('SELECT * FROM users WHERE username=?', [params['username']])[0]
            self.store_data(result)
            @success = 'Login successful'
            return true
        else
            @errors[:login] = 'Failed do login, wrong password'
            return false
        end
    end
    
    def signup(params)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        email_validation_regex = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/

        if (params['email'] =~ email_validation_regex).nil?()
            @errors[:signup] = 'Email is not correct, please use a valid email address'
            return false
        elsif not db.execute('SELECT id FROM users WHERE username=?', [params['username']]).empty?()
            @errors[:signup] = 'Failed do sign up, username already taken'
            return false
        elsif not db.execute('SELECT id FROM users WHERE email=?', [params['email']]).empty?()
            @errors[:signup] = 'Failed do sign up, email already in use'
            return false
        end

        file_name = SecureRandom.uuid
        FileUtils.copy(params['profile_pic']['tempfile'], "./public/img/#{file_name}")

        hashed_password = BCrypt::Password.create(params['password'])

        db.execute('INSERT INTO users (firstName, lastName, email, username, password, profilePic) VALUES (?, ?, ?, ?, ?, ?)', [
            params['first_name'], params['last_name'], params['email'], params['username'], hashed_password, file_name
        ])

        result = db.execute('SELECT * FROM users WHERE username=?', [params['username']])[0]
        self.store_data(result)

        @success = "Sign up successful"
        return true
    end

    def logged_in?()
        if @data != nil
            return true
        else
            return false
        end
    end
    
    def logout()
        @data = nil
    end
    
    def self.all()
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        result = db.execute('SELECT * FROM users')
        result.map { |row| self.new().store_data(row) }
    end
    
    def self.get(user_id)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true
        
        user = db.execute('SELECT * FROM users WHERE id=?', [user_id])[0]

        instance = self.new()
        instance.store_data(user)

        return instance
    end
end
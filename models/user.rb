class User
    attr_reader :data
    
    def initialize()
        @data = nil
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
    
    def authenticate(params)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        user = db.execute('SELECT id, password FROM users WHERE username=?', [params['username']])

        if user.length == 0
            return false
        end

        if BCrypt::Password.new(user[0]['password']) == params['password']
            result = db.execute('SELECT * FROM users WHERE username=?', [params['username']])[0]
            self.store_data(result)
            return true
        else
            return false
        end
    end

    def signup(params)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        p params
        if db.execute('SELECT id FROM users WHERE username=?', [params[:username]]).length != 0
            return false
        elsif db.execute('SELECT id FROM users WHERE email=?', [params[:email]]).length != 0
            return false
        end

        file_name = SecureRandom.uuid
        FileUtils.copy(params['profile_pic']['tempfile'], "./public/img/#{file_name}")

        hashed_password = BCrypt::Password.create(params['password'])

        db.execute('INSERT INTO users (firstName, lastName, email, username, password, profilePic) VALUES (?, ?, ?, ?, ?, ?)', [
            params['first_name'], params['last_name'], params['email'], params['username'], hashed_password, file_name
        ])

        result = db.execute('SELECT * FROM users WHERE username=?', [params['username']])[0]
        p result
        self.store_data(result)
        return true
    end

    def logged_in?()
        if self.data != nil
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
        # db.execute('INSERT INTO users (firstName, lastName, email, username, password, profilePic) VALUES (?, ?, ?, ?, ?, ?)', [
        #     'mika', 'ansersson', 'filip.a@gmail.com', 'torphage', 'somethinghashed', nil
        # ])
        result = db.execute('SELECT * FROM users')
        result.map { |row| self.new().store_data(row) }
        p result
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
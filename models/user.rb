class User < Model
    attr_reader :data, :errors, :success
    
    table User.name.downcase() + "s"

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

        user = User.get('username', params['username'])

        if user.data.keys.empty?()
            @errors[:login] = 'Failed do login, user does not exist'
            return false
        end
        
        if BCrypt::Password.new(user.data[:password]) == params['password']
            result = User.get("username", params['username'])
            self.store_data(result.data.values)
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
        elsif not User.all({username: params['username']}).empty?()
            @errors[:signup] = 'Failed do sign up, username already taken'
            return false
        elsif not User.all({email: params['email']}).empty?()
            @errors[:signup] = 'Failed do sign up, email already in use'
            return false
        end

        file_name = SecureRandom.uuid
        FileUtils.copy(params['profile_pic']['tempfile'], "./public/img/#{file_name}")

        hashed_password = BCrypt::Password.create(params['password'])

        User.create({
            firstName: params['first_name'],
            lastName: params['last_name'],
            email: params['email'],
            username: params['username'],
            password: hashed_password,
            profilePic: params[file_name]
        })

        @success = "Sign up successful"
        
        self.store_data(params)
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

    def create_document(params)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        Document.create({
            title: params['title'],
            owner: @data[:id],
            preview: "4f8ca52e-e888-4491-8f45-bb422b08c2a8"
        })
        document_id = db.execute('SELECT * FROM documents ORDER BY id DESC')[0]['id']

        Page.create({
            textContent: "",
            documentId: document_id,
            pageInt: 1
        })

        User.create({
            userId: @data[:id],
            documentId: document_id
        }, "documents_users")

        params["guests"].split(",").map{ |guest| guest.strip() }.each do |guest|
            guest_id = User.get('username', guest).data[:id]
            User.create({
                userId: guest_id,
                documentId: document_id
            }, "documents_users")
        end
    end
end
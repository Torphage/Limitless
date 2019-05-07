require 'sqlite3'
require 'pp'

require_relative '../models/model'
require_relative '../models/user'
require_relative '../models/document'
require_relative '../models/document_user'
require_relative '../models/page'

class Seeder
    def self.seed!        
        User.rebuild_table()
        Document.rebuild_table()
        DocumentUser.rebuild_table()
        Page.rebuild_table()

        User.create({first_name: "Guest", last_name: "User", email: "guest@guest.info", username: "GuestUser", password: "guest", profile_pic: nil})
    end
    
    def self.print!
        db = SQLite3::Database.new('db/data.db')

        pp(db.execute("SELECT * FROM users"))
        pp(db.execute("SELECT * FROM documents"))
        pp(db.execute("SELECT * FROM documents_users"))
        pp(db.execute("SELECT * FROM pages"))
    end
end


# bundle exec racksh -> Seeder.seed! -> reload!

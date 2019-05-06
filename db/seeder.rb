require 'sqlite3'
require 'pp'

require_relative '../models/model'
require_relative '../models/user'
require_relative '../models/document'
require_relative '../models/document_user'
require_relative '../models/page'

class Seeder
    def self.seed!
        db = SQLite3::Database.new('db/data.db')
        db.execute('DROP TABLE IF EXISTS users')
        
        db.execute("DROP TABLE IF EXISTS #{User.get_table_name}")
        db.execute("CREATE TABLE #{User.get_table_name} (#{User.get_columns().zip(User.get_args()).map{ |col,arg| "#{col} #{arg}" }.join(",")})")
        
        db.execute("DROP TABLE IF EXISTS #{Document.get_table_name}")
        db.execute("CREATE TABLE #{Document.get_table_name} (#{Document.get_columns().zip(Document.get_args()).map{ |col,arg| "#{col} #{arg}" }.join(",")})")

        db.execute("DROP TABLE IF EXISTS #{DocumentUser.get_table_name}")
        db.execute("CREATE TABLE #{DocumentUser.get_table_name} (#{DocumentUser.get_columns().zip(DocumentUser.get_args()).map{ |col,arg| "#{col} #{arg}" }.join(",")})")

        db.execute("DROP TABLE IF EXISTS #{Page.get_table_name}")
        db.execute("CREATE TABLE #{Page.get_table_name} (#{Page.get_columns().zip(Page.get_args()).map{ |col,arg| "#{col} #{arg}" }.join(",")})")        
        User.create({firstName: "Guest", lastName: "User", email: "guest@guest.info", username: "GuestUser", password: "guest", profilePic: nil})
    end
    
    def self.print!
        db = SQLite3::Database.new('db/data.db')

        pp(db.execute("SELECT * FROM users"))
        pp(db.execute("SELECT * FROM documents"))
        pp(db.execute("SELECT * FROM documents_users"))
        pp(db.execute("SELECT * FROM pages"))
    end
end


# bundle exec racksh i cmd -> Seeder.seed! -> reload!

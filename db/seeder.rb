require 'sqlite3'
require 'pp'

class Seeder
    def self.seed!
        db = SQLite3::Database.new('db/data.db')
        db.execute('DROP TABLE IF EXISTS users')

        db.execute('CREATE TABLE users (id INTEGER PRIMARY KEY AUTOINCREMENT,
                                        firstName VARCHAR(255) NOT NULL,
                                        lastName VARCHAR(255) NOT NULL,
                                        email VARCHAR(255) NOT NULL UNIQUE,
                                        username VARCHAR(255) NOT NULL UNIQUE,
                                        password VARCHAR(20) NOT NULL,
                                        profilePic VARCHAR(255))')

        db.execute('DROP TABLE IF EXISTS documents')

        db.execute('CREATE TABLE documents (id INTEGER PRIMARY KEY AUTOINCREMENT,
                                            title VARCHAR(255) NOT NULL,
                                            textContent VARCHAR(255),
                                            owner VARCHAR(255) NOT NULL)')

        db.execute('DROP TABLE IF EXISTS documents_users')

        db.execute('CREATE TABLE documents_users (userId INTEGER NOT NULL,
                                                  documentId INTEGER NOT NULL)')
                                            
        pp(db.execute("SELECT * FROM users"))
        pp(db.execute("SELECT * FROM documents"))
        pp(db.execute("SELECT * FROM documents_users"))
        
    end
    
    def self.print!
        db = SQLite3::Database.new('db/data.db')

        pp(db.execute("SELECT * FROM users"))
        pp(db.execute("SELECT * FROM documents"))
        pp(db.execute("SELECT * FROM documents_users"))
    end
end


# bundle exec racksh i cmd -> Seeder.seed! -> reload!

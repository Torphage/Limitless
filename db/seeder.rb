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
        self.standard()
    end    

    def self.standard()
        files = Dir["db/**/*.csv"]
        files.each do |file|
            class_name = file.match(/\/([^_]*)\_/).captures[0]
            values = File.readlines(file)
            values.shift
            header = values.shift.strip.split(",")
            values.each do |row|
                columns = row.split(",")
                dict = header.map(&:to_sym).zip(columns).to_h
                Object.const_get(class_name.capitalize).create(dict)
            end
        end
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

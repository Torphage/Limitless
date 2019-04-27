require_relative 'page'

class Document < Model
    attr_accessor :data

    table Document.name.downcase() + "s"

    def store_data(db_array)
        @data = {
            id: 		 db_array[0],
            title:	     db_array[1],
            owner: 		 db_array[2],
            preview:	 db_array[3],
            pages:       Page.get(db_array[0]),
            users:       Document.allowedUsers(db_array[0], db_array[2])
        }
    end

    def self.addPage(params)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true
        
        int = db.execute('SELECT pageInt FROM pages WHERE documentId ORDER BY documentId ASC', [@data[:id]]) + 1

        db.execute('INSERT INTO pages (textContent, documentId, pageInt) VALUES (?, ?, ?)', [params['textContent'], @data[:id], int])
    end

    def deletePage(page)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        db.execute('DELETE FROM pages WHERE documentId=? AND pageInt=?', [@data[:id], page])
    end

    def save(params, change)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        if params["pageInt"].to_i >= 1
            @data[:pages].save(params)
        end

        return self
    end

    def self.allowedUsers(document_id, owner_id)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        allowed_users = db.execute('SELECT userId FROM documents_users WHERE documentId=?', [document_id])
        allowed_users << owner_id

        return allowed_users
    end

    def self.all()
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        result = db.execute('SELECT * FROM documents')
        result.map { |row| self.new().store_data(row) }
    end
    
    def self.get(document_id)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true
        
        document = db.execute('SELECT * FROM documents WHERE id=?', [document_id])[0]

        instance = self.new()
        instance.store_data(document)

        return instance
    end
end
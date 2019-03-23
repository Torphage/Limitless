class Document
    attr_reader :data
    
    def store_data(db_array)
        @data = {
            id: 		 db_array[0],
            title:	     db_array[1],
            textContent: db_array[2],
            owner: 		 db_array[3],
            preview:	 db_array[4]
        }
    end

    def save(params)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        document = db.execute('REPLACE INTO documents (id, title, textContent, owner, preview) VALUES (?, ?, ?, ?, ?)', 
            [
                @data[:id],
                @data[:title],
                params['textContent'],
                @data[:owner],
                @data[:preview]
            ]
        )
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
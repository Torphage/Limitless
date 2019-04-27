class Page < Model
    attr_accessor :data, :documentId

    table Page.name.downcase() + "s"
    
    def initialize(document_id)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        if Page.read([["id"], {documentId: document_id}]).length == 0
            db.execute('INSERT INTO pages (textContent, documentId, pageInt) VALUES ("", ?, 1)', [document_id])
        end

        @documentId = document_id
    end

    def store_data(db_array)
        @data = []
        db_array.each do |data|
            @data << {
                id: 		 data[0],
                textContent: data[1],
                pageInt:     data[3]
            }
        end
    end
    
    def save(params)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true
        
        existing_pages = Page.read([["id"], {pageInt: params['pageInt']}])

        if existing_pages.length == 0
            Page.create({
                textContent: params['textContent'],
                documentId: @documentId,
                pageInt: params['pageInt']
            })
        else 
            Page.update([
                {
                    textContent: params['textContent']
                },
                {
                    documentId: @documentId,
                    pageInt: params['pageInt']
                }
            ])
        end

        pages = Page.read([
            ["*"],
            {
                documentId: @documentId
            }
        ])
        self.store_data(pages)
    end

    def self.get(document_id)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true
        
        pages = Page.read([["*"], {documentId: document_id}])

        instance = self.new(document_id)
        instance.store_data(pages)

        return instance
    end
end
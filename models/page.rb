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
        
        updated = self.save_change(params)
        p updated
        existing_pages = Page.read([["id"], {pageInt: params[:pageInt]}])

        if existing_pages.length == 0
            Page.create({
                textContent: updated,
                documentId: @documentId,
                pageInt: params[:pageInt]
            })
        else
            Page.update([
                {
                    textContent: updated
                },
                {
                    documentId: @documentId,
                    pageInt: params[:pageInt]
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

    def save_change(params)
        textContent = Page.read([["textContent"], {pageInt: params[:pageInt]}])
        newText = ""
        params[:textContent].each do |element|
            if element[:"0"] == 0 or element[:"0"] == 1
                newText += element[:"1"]
            end
        end
        return newText
    end

    def self.get_pages(document_id)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true
        
        pages = Page.read([["*"], {documentId: document_id}])

        instance = self.new(document_id)
        instance.store_data(pages)

        return instance
    end
end
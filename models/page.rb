class Page < Model
    attr_accessor :data, :documentId

    table Page.name.downcase() + "s"

    def store_data(db_array)
        @data = []
        db_array.each do |data|
            @data << {
                id: 		 data[0],
                textContent: data[1],
                documentId:  data[2],
                pageInt:     data[3]
            }
        end
    end
    
    def save(params)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true
        
        updated = self.save_change(params)
    
        existing_pages = Page.all({ documentId: @data[:documentId] }).data.keys

        if existing_pages.length > 0
            Page.update({ textContent: updated },
                        { documentId: @data[:documentId], pageInt: params[:pageInt]})
        end

        pages = Page.get_pages(@data[:documentId]).data.values
        self.store_data(pages)
    end

    def save_change(params)
        p params[:pageInt]
        p @data[params[:pageInt] - 1][:documentId]
        p @data
        p Page.all({pageInt: params[:pageInt], documentId: @data[params[:pageInt] - 1][:documentId] } )
        textContent = Page.all({pageInt: params[:pageInt], documentId: @data[params[:pageInt] - 1][:documentId] } ).data[:textContent]
        newText = ""
        params[:textContent].each do |element|
            if element[:"0"] == 0 or element[:"0"] == 1
                newText += element[:"1"]
            end
        end
        return newText
    end
end
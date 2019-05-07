class Page < Model
    table 'pages'

    column 'page_id', 'INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'
    column 'text_content', 'TEXT'
    column 'document_id', 'INTEGER NOT NULL REFERENCES documents(document_id) ON UPDATE CASCADE'
    column 'page_number', 'INTEGER NOT NULL'

    def self.create(dict, &block)
        super(dict)
        if block_given?
            DocumentUser.create(block.yield)
        end
    end

    def get_changes(change)
        newText = ""
        change[:text_content].each do |element|
            if element[:"0"] == 0 or element[:"0"] == 1
                newText += element[:"1"]
            end
        end
        return newText
    end
end
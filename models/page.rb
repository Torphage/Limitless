class Page < Model
    table_name 'pages'

    column 'id', 'INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'
    column 'textContent', 'TEXT'
    column 'documentId', 'INTEGER NOT NULL'
    column 'pageInt', 'INTEGER NOT NULL'

    def get_changes(change)
        newText = ""
        change[:textContent].each do |element|
            if element[:"0"] == 0 or element[:"0"] == 1
                newText += element[:"1"]
            end
        end
        return newText
    end
end
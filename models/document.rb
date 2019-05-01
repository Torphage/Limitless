require_relative 'page'

class Document < Model
    attr_accessor :data

    table Document.name.downcase() + "s"

    def store_data(db_array)
        p db_array
        @data = {
            id: 		 db_array[0],
            title:	     db_array[1],
            owner: 		 db_array[2],
            preview:	 db_array[3],
            pages:       Page.all({documentId: db_array[0]}),
            users:       Document.allowedUsers(db_array[2])
        }
        p @data
    end

    def self.addPage(params)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true
        p Page.get('documentId', @data[:id]).data.values
        int = Page.get('documentId', @data[:id]).data.values + 1
        p int
        Page.create({textContent: params['textContent'], docuemntId: @data[:id], pageInt: int})
        index = 0
        @data[:pages].each do |page|
            if page.data[:id] == int
                @data[:pages].delete_at(index)
            end
            i += 1
        end
    end

    def deletePage(page)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        Page.delete({pages: @data[:id], pageInt: page})
    end

    def save(params)
        if params[:pageInt] >= 1
            @data[:pages].save(params)
        end

        return self
    end

    def self.allowedUsers(owner_id)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        document_id = db.execute('SELECT * FROM documents ORDER BY id DESC')[0]['id']

        allowed_users = db.execute("SELECT * FROM documents_users WHERE documentId = ?", document_id).map{ |user| user['userId'] }.flatten()
        allowed_users << owner_id.to_i

        return allowed_users
    end
end
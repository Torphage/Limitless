require_relative 'page'

class Document < Model
    table 'documents'

    column 'document_id', 'INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'
    column 'title', 'VARCHAR(255) NOT NULL'
    column 'user_id', 'INTEGER NOT NULL REFERENCES users(user_id) ON UPDATE CASCADE'
    column 'preview', 'VARCHAR(255)'

    def allowed_users(users)
        @allowed_users = users
    end

    def get_allowed_users
        @allowed_users
    end

    def pages(pages)
        @pages = pages
    end

    def get_pages
        @pages
    end

    def self.create(dict)
        document_id = super
        Page.create({document_id: document_id, text_content: "", page_number: 1}) { {user_id: dict[:user_id], document_id: document_id} }
        return document_id
    end
end
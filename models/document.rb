require_relative 'page'

class Document < Model
    table_name 'documents'

    column 'id', 'INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT'
    column 'title', 'VARCHAR(255) NOT NULL'
    column 'owner', 'VARCHAR(255) NOT NULL'
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
end
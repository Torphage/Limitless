class DocumentUser < Model
    table 'documents_users'
    
    column 'document_id', 'INTEGER NOT NULL REFERENCES documents(document_id) ON UPDATE CASCADE'
    column 'user_id', 'INTEGER NOT NULL REFERENCES users(user_id) ON UPDATE CASCADE'
end
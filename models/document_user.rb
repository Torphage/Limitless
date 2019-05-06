class DocumentUser < Model
    table_name 'documents_users'
    
    column 'documentId', 'INTEGER NOT NULL'
    column 'userId', 'INTEGER NOT NULL'
end
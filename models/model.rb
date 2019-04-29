class Model
    def self.table(table)
        @table = table
    end

    def self.get(id)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true
        
        result = db.execute("SELECT * FROM #{@table} WHERE id=?", [id])[0]

        instance = self.new()
        instance.store_data(result)
        
        return instance
    end

    def self.all()
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        result = db.execute("SELECT * FROM #{@table}")
        result.map { |row| self.new().store_data(row) }
    end

    def self.create(dict)
        db = SQLite3::Database.new('db/data.db')

        db.execute("INSERT INTO #{@table} (#{dict.keys.map{|k| k}.join(',')}) VALUES (#{dict.keys.map{ |_| '?'}.join(",")})", dict.values.map{ |v| v})
    end

    def self.read(dict)
        db = SQLite3::Database.new('db/data.db')

        return db.execute("SELECT #{dict[0].join(", ")} FROM #{@table} WHERE #{dict[1].keys.map{ |k| "#{k}=?"}.join(' AND ')}", dict[1].values.map{ |v| v})
    end

    def self.update(dict)
        db = SQLite3::Database.new('db/data.db')

        db.execute("UPDATE #{@table} SET #{dict[0].keys.map{ |k| "#{k}=?"}.join(", ")} WHERE #{dict[1].keys.map{ |k| "#{k}=?" }.join(" AND ")}", dict.map{ |temp| temp.values.map{ |v| v } }.flatten())
    end

    def self.delete(dict)
        db = SQLite3::Database.new('db/data.db')

        db.execute("DELETE FROM #{@table} WHERE #{dict.values.map{ |k| "#{k}=?"}.join(' AND ')}", dict.values.map{ |v| v })
    end
end
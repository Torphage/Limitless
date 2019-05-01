class Model
    def self.table(table)
        @table = table
    end

    def self.get(column, value, table_name=@table)
        db = SQLite3::Database.new('db/data.db')

        result = db.execute("SELECT * FROM #{table_name} WHERE #{column} = ?", value)[0]

        if result
            instance = self.new()
            instance.store_data(result)
            
            return instance
        else
            return []
        end
    end

    def self.all(dict=nil)
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        if dict
            result = db.execute("SELECT * FROM #{@table} WHERE #{dict.keys.map{ |k| k.to_s }.join('= ? AND ')} = ?", dict.values)
        else
            result = db.execute("SELECT * FROM #{@table}")
        end

        if result
            instances = []
            result.each do |row|
                instance = self.new()
                instance.store_data(row)

                instances << instance
            end
            return instances
        else
            return []
        end
    end

    def self.create(dict, table_name=@table)
        db = SQLite3::Database.new('db/data.db')

        db.execute("INSERT INTO #{table_name} (#{dict.keys.map{ |k| k.to_s }.join(',')}) VALUES (#{dict.keys.map{ |_| '?'}.join(",")})", dict.values)
    end

    def self.update(column, values)
        db = SQLite3::Database.new('db/data.db')

        db.execute("UPDATE #{@table} SET #{column.keys.map{ |k| "#{k}=?"}.join(", ")} WHERE #{values.keys.map{ |k| "#{k}=?" }.join(" AND ")}", [column.values, values.values].flatten())
    end

    def self.delete(dict)
        db = SQLite3::Database.new('db/data.db')

        db.execute("DELETE FROM #{@table} WHERE #{dict.keys.map{ |k| k.to_s }.join(' = ? AND ')} = ?", dict.values)
    end
end
#all
#first/get
#create
#update
#delete

class Model
    def self.table(name)
        @table = name
    end

    def self.get_table
        @table
    end

    def self.column(name, args)
        @args ||= []
        @args << args
        @columns ||= []
        @columns << name
        attr_reader(name)
    end

    def self.get_columns
        @columns
    end

    def self.get_args
        @args
    end

    def initialize(dict)
        self.class.get_columns().each do |column|
            if dict.key?(column)
                key = "@#{column}".to_sym
                instance_variable_set(key, dict[column])
            end
        end
    end

    def self.rebuild_table()
        db = SQLite3::Database.new('db/data.db')

        self.drop_table()
        db.execute("CREATE TABLE #{self.get_table} (#{self.get_columns.zip(self.get_args).map{ |column, args| "#{column} #{args}" }.join(", ")})")
    end

    def self.get(dict, &block)
        self.all(dict, limit=" LIMIT 1") { yield if block_given? }[0]
    end

    def self.all(dict, limit="", conditional="AND", &block) 
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true
        object = dict.select { |key, value| @columns.include?(key.to_s) }

        if (yield if block_given?)
            args = block.yield
            string = self.join(args)
            table = args[:join].get_table
        else
            string = "SELECT * FROM #{@table}"
            table = self.get_table
        end

        condition = (not object.empty?()) ? " WHERE #{table}.#{object.keys.map(&:to_s).join(" = ? #{conditional} #{table}.")} = ?" : ""
        result = db.execute(string + condition + limit, object.values)

        result.map { |row| self.new(row) }
    end

    def self.create(dict)
        db = SQLite3::Database.new('db/data.db')
        object = dict.select { |key, value| @columns.include?(key.to_s) }

        db.execute("INSERT INTO #{@table} (#{object.keys.map(&:to_s).join(',')}) VALUES (#{object.keys.map{ |_| '?'}.join(",")})", object.values)
        db.execute('SELECT last_insert_rowid()')[0][0]
    end

    def self.update(change, condition)
        db = SQLite3::Database.new('db/data.db')
        object = change.select { |key, value| @columns.include?(key.to_s) }
        
        db.execute("UPDATE #{@table} SET #{object.keys.map(&:to_s).join("=?,")}=? WHERE #{condition.keys.map(&:to_s).join("=? AND ")}=?", (object.values << condition.values).flatten())
    end

    def self.delete(dict)
        db = SQLite3::Database.new('db/data.db')
        object = dict.select { |key, value| @columns.include?(key.to_s) }
        
        db.execute("DELETE FROM #{@table} WHERE #{object.keys.map(&:to_s).join('=? AND ')}=?", object.values)
    end
    
    private

    def self.drop_table()
        db = SQLite3::Database.new('db/data.db')

        db.execute("DROP TABLE IF EXISTS #{self.get_table}")
    end
    
    def self.join(dict)
        core = "SELECT DISTINCT #{self.get_table}.* FROM #{self.get_table}"

        join = " INNER JOIN #{dict[:join].get_table} USING (#{dict[:join].get_table[0..-2]}_id)"
        through = dict.key?(:through) ? " INNER JOIN #{dict[:through].get_table} USING (#{self.get_table[0..-2]}_id)" : ""

        return core + through + join
    end
end
#all
#first/get
#create
#update
#delete

class Model
    def self.table_name(name)
        @table_name = name
    end

    def self.get_table_name
        @table_name
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

    def self.get(dict, &block)
        self.all(dict, " LIMIT 1") { yield if block_given? }[0]
    end

    def self.all(dict, limit="", &block) 
        db = SQLite3::Database.new('db/data.db')
        db.results_as_hash = true

        if (yield if block_given?)
            args = block.yield
            string = self.join(args)
            table_name = args[:join].get_table_name
        else
            string = "SELECT * FROM #{@table_name}"
            table_name = self.get_table_name
        end

        condition = (not dict.empty?()) ? " WHERE #{table_name}.#{dict.keys.map{ |k| k.to_s }.join(" = ? AND #{table_name}.")} = ?" : ""
        result = db.execute(string + condition + limit, dict.values)

        result.map { |row| self.new(row) }
    end

    def self.create(dict)
        db = SQLite3::Database.new('db/data.db')

        db.execute("INSERT INTO #{@table_name} (#{dict.keys.map(&:to_s).join(',')}) VALUES (#{dict.keys.map{ |_| '?'}.join(",")})", dict.values)
        db.execute('SELECT last_insert_rowid()')[0][0]
    end

    def self.update(change, condition)
        db = SQLite3::Database.new('db/data.db')

        db.execute("UPDATE #{@table_name} SET #{change.keys.map(&:to_s).join("=?,")}=? WHERE #{condition.keys.map(&:to_s).join("=? AND ")}=?", (change.values << condition.values).flatten())
    end

    def self.delete(dict)
        db = SQLite3::Database.new('db/data.db')
        
        db.execute("DELETE FROM #{@table_name} WHERE #{dict.keys.map(&:to_s).join('=? AND ')}=?", dict.values)
    end
    
    private
    
    def self.join(dict)
        return "SELECT #{self.get_table_name}.* FROM #{dict[:join].get_table_name}"\
            " INNER JOIN #{dict[:through].get_table_name} ON #{dict[:through].get_table_name}.#{dict[:join].name.downcase()}Id = #{dict[:join].get_table_name}.id"\
            " INNER JOIN #{self.get_table_name} ON #{self.get_table_name}.id = #{dict[:through].get_table_name}.#{self.name.downcase()}Id"
    end
end
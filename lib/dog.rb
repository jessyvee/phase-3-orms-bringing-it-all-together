class Dog
    attr_accessor :id, :name, :breed
    def initialize(id: nil, name: "", breed: "")
        @id = id
        @name = name
        @breed = breed
    end
    def self.create_table
        sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
            )
            SQL
            DB[:conn].execute(sql)
    end
    def save
        sql = <<-SQL
        INSERT INTO dogs (name,breed)
        VALUES (?,?)
        SQL
       DB[:conn].execute(sql, self.name, self.breed)
    end
        
        def self.create(name:,breed:)
            dog = Dog.new(name: name, breed: breed)
            dog.save
        end

        def self.drop_table
            sql = <<-SQL
              DROP TABLE IF EXISTS dogs;
            SQL
            
            DB[:conn].execute(sql)
          end
           
          def save
            if self.id
                self.update
            else 
                sql = <<-SQL
                INSERT INTO dogs (name,breed)
                VALUES (?,?)
                    SQL
                    DB[:conn].execute(sql, self.name, self.breed)
                    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
            end
            self
        end

        def self.new_from_db(row)
            dog = self.new
            dog.id = row[0]
            dog.name = row[1]
            dog.breed = row[2]
            dog
          end
        
          def self.all
            sql = "SELECT * FROM dogs"
            DB[:conn].execute(sql).map do |row|
              self.new_from_db(row)
            end
          end
        
          def self.find_by_name(name)
            sql = "SELECT * FROM dogs WHERE name = ? LIMIT 1"
            DB[:conn].execute(sql, name).map do |row|
              self.new_from_db(row)
            end.first
          end
        
          def self.find(id)
            sql = "SELECT * FROM dogs WHERE id = ? LIMIT 1"
            DB[:conn].execute(sql, id).map do |row|
              self.new_from_db(row)
            end.first
        end
        end
require 'pry'
class Dog

    attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
        # binding.pry
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql =  <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,   
        name TEXT,
        breed TEXT
        )
        SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
        sql = <<-SQL
        DROP TABLE dogs
        SQL
        DB[:conn].execute(sql)
    end

    def save
        sql = <<-SQL
        INSERT INTO dogs (name, breed) VALUES (?, ?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        self
    end

    def self.create(name:, breed:)
        keys = [:name, :breed]
        values = [name, breed]
        hash = keys.zip(values).to_h
        dog = self.new(hash)
        dog.save
    end

    def self.new_from_db(row)
        # binding.pry
        new_dog = self.new(id: row[0], name: row[1], breed: row[2])
        new_dog
    end

    def self.find_by_id(id)
        sql = <<-SQL
          SELECT * FROM dogs WHERE id = ?
          SQL
        row = DB[:conn].execute(sql, id).first
        dog_found = self.new(id: row[0], name: row[1], breed: row[2])
    end

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
          SELECT * FROM dogs WHERE name = ? AND breed = ?
          SQL
        dog = DB[:conn].execute(sql, name, breed)
        if !dog.empty?

            dog_data = dog[0]
            dog = self.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
        else
            dog = self.create(name: name, breed: breed)
        end
        dog
    end

    def self.find_by_name (name)
        sql = <<-SQL
          SELECT * FROM dogs WHERE NAME = ?
          SQL
        dog = DB[:conn].execute(sql, name).first
        dog = self.new(id: dog[0], name: dog[1], breed: dog[2])
    end

    def update
        sql = "UPDATE dogs SET name = ?, breed = ? WHERE id = ?"
        DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
        



end
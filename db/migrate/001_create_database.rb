class CreateDatabase < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column "name",      :string,    :limit => 16, :default => "", :null => false
      t.column "passwd",    :string,    :limit => 64, :default => "", :null => false
	  t.column "passwd2",   :string,    :limit => 64, :default => "", :null => false
      t.column "email",     :string,    :limit => 32, :default => "", :null => false
      t.column "timestamp", :timestamp,                               :null => false
      t.column "reg_hash",  :string,    :limit => 64
    end

	add_index "users", ["name"], :name => "name"
	add_index "users", ["timestamp"], :name => "timestamp"
	
	create_table "permissions", :force => true do |t|
	  t.column "user_id",      :integer,                              :null => false
      t.column "admin",        :boolean,               :default => false
      t.column "active",       :integer,  :limit => 1, :default => 0
	end
	
	add_index "permissions", ["user_id"], :name => "user_id"
	
    create_table "grammars", :force => true do |t|
      t.column "name",         :string,    :limit => 16, :default => "", :null => false
      t.column "user_id",      :integer,                                 :null => false
      t.column "version",      :integer,   :limit => 4,                  :null => false
      t.column "version_type", :string,    :limit => 8,  :default => "", :null => false
      t.column "desc",         :text
      t.column "public",       :boolean
      t.column "created",      :timestamp,                               :null => false
      t.column "modified",     :timestamp,                               :null => false
    end
	
	add_index "grammars", ["name"], :name => "name"
	add_index "grammars", ["user_id"], :name => "user_id"
	add_index "grammars", ["user_id","name"], :name => "user_id_name"
	add_index "grammars", ["public"], :name => "public"
	add_index "grammars", ["version"], :name => "version"
	add_index "grammars", ["version_type"], :name => "version_type"

    create_table "rules", :force => true do |t|
      t.column "grammar_id",  :integer,                                :null => false
      t.column "pattern",     :string,  :limit => 256, :default => "", :null => false
      t.column "translation", :string,  :limit => 256, :default => "", :null => false
      t.column "name",        :string,  :limit => 32,  :default => "", :null => false
	  t.column "priority",    :integer, :limit => 3
    end
	
	add_index "rules", ["name"], :name => "name"
	add_index "rules", ["priority"], :name => "priority"
	add_index "rules", ["name","priority"], :name => "name_priority"
	add_index "rules", ["grammar_id"], :name => "grammar_id"

  end

  def self.down
    drop_table :rules
	drop_table :grammars
    drop_table :users
  end
end

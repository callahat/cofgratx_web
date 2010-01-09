class CreateDatabase < ActiveRecord::Migration
  def self.up
    create_table "grammars", :force => true do |t|
      t.string   "name",         :limit => 16, :default => "", :null => false
      t.integer  "user_id",                                    :null => false
      t.integer  "version",                                    :null => false
      t.string   "version_type", :limit => 8,  :default => "", :null => false
      t.text     "desc"
      t.boolean  "public"
      t.datetime "created",                                    :null => false
      t.datetime "modified",                                   :null => false
    end
    add_index "grammars", ["name"], :name => "name"
    add_index "grammars", ["public"], :name => "public"
    add_index "grammars", ["user_id", "name"], :name => "user_id_name"
    add_index "grammars", ["user_id"], :name => "user_id"
    add_index "grammars", ["version"], :name => "version"
    add_index "grammars", ["version_type"], :name => "version_type"
  
    create_table "permissions", :force => true do |t|
      t.integer "user_id",                                 :null => false
      t.boolean "admin",                :default => false
      t.integer "active",  :limit => 1, :default => 0
    end
    add_index "permissions", ["user_id"], :name => "user_id"
  
    create_table "rules", :force => true do |t|
      t.integer "grammar_id",                                 :null => false
      t.string  "pattern",     :limit => 256, :default => "", :null => false
      t.string  "translation", :limit => 256
      t.string  "name",        :limit => 32,  :default => "", :null => false
      t.integer "priority",    :limit => 3
    end
    add_index "rules", ["grammar_id"], :name => "grammar_id"
    add_index "rules", ["name", "priority"], :name => "name_priority"
    add_index "rules", ["name"], :name => "name"
    add_index "rules", ["priority"], :name => "priority"

    create_table "users", :force => true do |t|
      t.string   "name",      :limit => 16, :default => "", :null => false
      t.string   "passwd",    :limit => 64, :default => "", :null => false
      t.string   "passwd2",   :limit => 64, :default => "", :null => false
      t.string   "email",     :limit => 32, :default => "", :null => false
      t.datetime "timestamp",                               :null => false
      t.string   "reg_hash",  :limit => 64
    end
    add_index "users", ["name"], :name => "name"
    add_index "users", ["timestamp"], :name => "timestamp"
  end

  def self.down
	drop_table :grammars
    drop_table :permissions
    drop_table :rules
    drop_table :users
  end
end

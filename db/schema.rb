# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100112051615) do

  create_table "grammars", :force => true do |t|
    t.string   "name",         :limit => 16, :default => "", :null => false
    t.integer  "user_id",                                    :null => false
    t.integer  "version",                                    :null => false
    t.string   "version_type", :limit => 8,  :default => "", :null => false
    t.text     "desc"
    t.boolean  "public"
    t.datetime "created_at"
    t.datetime "updated_at"
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

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :default => "", :null => false
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "users", :force => true do |t|
    t.string   "name",       :limit => 16, :default => "", :null => false
    t.string   "passwd",     :limit => 64, :default => "", :null => false
    t.string   "passwd2",    :limit => 64, :default => "", :null => false
    t.string   "email",      :limit => 32, :default => "", :null => false
    t.string   "reg_hash",   :limit => 64
    t.datetime "created_at"
  end

  add_index "users", ["name"], :name => "name"

end

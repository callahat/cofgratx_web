class AutoTimestamps < ActiveRecord::Migration
  def self.up
    rename_column :grammars, :created,   :created_at
	rename_column :grammars, :modified,  :updated_at
	rename_column :users,    :timestamp, :created_at
  end

  def self.down
    rename_column :grammars, :created_at, :created
	rename_column :grammars, :updated_at, :modified
	rename_column :users,    :created_at, :timestamp
  end
end

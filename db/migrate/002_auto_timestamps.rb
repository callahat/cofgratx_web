class AutoTimestamps < ActiveRecord::Migration
  def self.up
    add_column :grammars, :created_at, :datetime
	add_column :grammars, :updated_at, :datetime
	add_column :users,    :created_at, :datetime
	
	Grammar.find(:all).each{|g|
	  g.update_attributes(:created_at => g.created, :updated_at => g.modified)}
	User.find(:all).each{|u|
	  u.update_attributes(:created_at => u.timestamp)}
	
    remove_column :grammars, :created
	remove_column :grammars, :modified
	remove_column :users,    :timestamp
  end

  def self.down
    add_column :grammars, :created,   :datetime
	add_column :grammars, :modified,  :datetime
	add_column :users,    :timestamp, :datetime
	
	Grammar.find(:all).each{|g|
	  g.update_attributes(:created => g.created_at, :modified => g.updated_at)}
	User.find(:all).each{|u|
	  u.update_attributes(:timestamp => u.created_at)}
	
    remove_column :grammars, :created_at
	remove_column :grammars, :updated_at
	remove_column :users,    :created_at
  end
end

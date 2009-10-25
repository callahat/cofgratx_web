class Grammar < ActiveRecord::Base
  has_many :rules
  
  validates_presence_of :name, :user_id
  
  before_create :initial
  before_update :modify
  
  def initial
    write_attribute "created",Time.now
	write_attribute "modified",Time.now
	write_attribute "version",1 if version.nil?
	write_attribute "version_type",1
  end
  
  def modify
    write_attribute "modified",Time.now
  end
end
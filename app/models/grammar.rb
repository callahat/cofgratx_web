class Grammar < ActiveRecord::Base
  has_many :rules
  
  validates_presence_of :name, :user_id
  
  before_create :initial
  
  def initial
    write_attribute "version",1 if version.nil?
    write_attribute "version_type",1
  end
end
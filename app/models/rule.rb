class Rule < ActiveRecord::Base
  belongs_to :grammar
  
  validates_presence_of :name,:pattern,:grammar_id
end
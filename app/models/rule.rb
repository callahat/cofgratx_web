class Rule < ActiveRecord::Base
  belongs_to :grammar
  
  validates_presence_of :name,:pattern,:grammar_id
  
  before_create :clean_input
  after_create :clean_input
  before_update :clean_input
    
  def clean
  
  end
  
  def to_CFG_pat_a
    parse_input(pattern)
  end
  
  def to_CFG_tx_a
    parse_input(translation)
  end

  def cleaned_pattern
    parse_input(pattern).inspect.to_s[1..-2]
  end
  
  def cleaned_translation
    parse_input(translation).inspect.to_s[1..-2]
  end
  
protected
  def clean_input
    write_attribute "pattern", cleaned_pattern
    write_attribute "translation", cleaned_translation
  end

  def parse_input(string)
    a = []
    
    #this regexp pulls all valid evalable parts into $2, and does not pull in stuff unlawfully escaped
    #print "\nstring: " + string
    while (string =~ /(^[\["\/]*?(\[.*?\]|\".*?\"|\/.*?\/|\d+|:[a-z]),?\s*)/) do
      keeper = $2.dup
      kipple = $1.dup
      if ($2 =~ /^\[(.*?)\]/)
        a << parse_input($1)
      elsif keeper && keeper[-2..-2] != "\\" #having an escape character right before end quote could be bad.
        a << Rails.module_eval(keeper) #dangerous without the regexp. even so, still dangerous
      end
      string = string[kipple.length..-1]
    end
    return a
  end
end
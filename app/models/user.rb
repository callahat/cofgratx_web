require 'digest/sha1'

class User < ActiveRecord::Base
  has_one :permission
  has_many :grammars

  def self.authenticate(user)
    return nil if user.nil?
    find(:first, :conditions => ["name = ? AND passwd = ?", user[:name], sha1(user[:passwd])])
  end
  
  def self.authenticate?(name, pass)
    user = self.authenticate(name, pass)
    return false if user.nil?
    return true if user.name == name
    
    false
  end

protected

  def self.sha1(pass)
    Digest::SHA1.hexdigest("4535--#{pass}--9878")
  end

  before_create :cryptpass
  before_update :cryptpass
  
  before_create :initialize_user
  after_create :send_reg_mail

  def cryptpass
    unless passwd == '' and passwd2 == ''
      write_attribute "passwd", self.class.sha1(passwd)
      write_attribute "passwd2", self.class.sha1(passwd2)
    end
  end
  
  def initialize_user
    write_attribute "active", 0
    write_attribute "reg_hash", self.class.sha1("1983-#{name}-#{Time.now}-")
  end
  
  def send_reg_mail
    unless $bulk_loading
      subject = "COFGRATX registration email"
      Emailer.deliver_reg_mail(self.email, subject, self.name, self.reg_hash)
    end
  end

  validates_uniqueness_of :name, :on => :create
  validates_presence_of :name,:passwd, :passwd2, :email, :on => :create
  validates_format_of :email, :with => /^.*?@.*?\..{2,4}$/,:on => :create
  
  def validate
    if passwd != passwd2 
      errors.add("passwd","passwords do not match")
      errors.add("passwd2","passwords do not match")
      false
    else
      return true
    end
  end
end

class Emailer < ActionMailer::Base
   def reg_mail(recipient, subject, username, reg_hash)
      @username = username
      @reg_hash = reg_hash
      @headers = {}

     mail( :subject => subject,
           :to      => recipient,
           :from    => 'noreply@callahat.net' )
   end

end

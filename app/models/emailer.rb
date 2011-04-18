class Emailer < ActionMailer::Base
   def reg_mail(recipient, subject, username, reg_hash, sent_at = Time.now)
      @subject = subject
      @recipients = recipient
      @from = 'noreply@callahat.net'
      @sent_on = sent_at
      @body["username"] = username
      @body["reg_hash"] = reg_hash
      @headers = {}
   end
end

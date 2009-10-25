class EmailerController < ApplicationController
#   ##Probably don't need this controller, unless I'm going to make a page to send announcements.
#   ##For now the only emails that will be sent will be from registration
#   
#   def index
#   end
#   
#   def sendmail
#      if session[:player][:handle] == 'Fhugue'
#         email = @params["email"]
#	   recipient = email["recipient"]
#	   subject = email["subject"]
#	   message = email["message"]
#        Emailer.deliver_contact(recipient, subject, message)
#         return if request.xhr?
#         render :text => 'Message sent successfully'
#      else
#         render :text => "Sorry, #{session[:player][:handle]} must be admin to use this page. You are not."
#      end
#   end
  
end
# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_cofgratx_session_id'
  
  layout 'mainlayout'
  
  def check_signed_in
	if session[:user].nil?
		redirect_to :controller => 'users', :action => 'login'
		return false
	end
  end
  
end

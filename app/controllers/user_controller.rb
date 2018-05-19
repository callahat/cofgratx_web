class UserController < ApplicationController

  def login
    if flash[:notice].nil?
      reset_session
    end
  end

  def logout
    reset_session
    flash[:notice] = "You have sucessfully logged out. Thanks for visiting."
    redirect_to :controller => 'default', :action => 'home'
  end

  def activation
    @user = User.find_by_name(params[:bar])
    if @user.nil?
      flash[:notice] = "Unable to find user \"" + params[:bar] + "\""
    elsif @user.permission.active == 1
      flash[:notice] = "This account is already active, you should be able to login"
    elsif @user.permission.active != 0
      flash[:notice] = "We're sorry, but we are unable to activate your account"
    elsif (@user.reg_hash == params[:foo]) && @user.permission.active == 0
      @user.permission.update_attributes(:active => 1)
      flash[:notice] = "Thank you, \"" + @user.name + "\" has been activated. You may sign in and use the application."
    else
      flash[:notice] = "We're sorry, we are unable to activate your account"
    end
    redirect_to :action => 'login'
  end

  def verify
    @user = User.new(user_params)
    @auser = User.authenticate(user_params)

    if @auser.nil?
      flash[:notice] = "Invalid password."
      flash[:notice] = "User \"" + params[:user][:name] + "\" not found." if User.find_by_name(params[:user][:name]).nil?
      @user.passwd = ""
      render :action => 'login'
    elsif @auser.permission.nil?
      flash[:notice] = "This user's account is broken. Please contact an administrator."
      render :action => 'login'
    elsif @auser.permission.active == 0
      flash[:notice] = "Account is not yet active. Please follow the link in your registration email."
      render :action => 'login'
    else
      session[:user] = @auser
      redirect_to workpad_grammar_url
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      permission = Permission.new
      permission.user_id = @user.id
      print "Failed to save permission row for user \"" + @user.name + "\"" if ! permission.save
      flash[:notice] = 'User was successfully created. You will need to activate the account before signing in, however.'
      redirect_to :controller => 'default', :action => 'home'
    else
      @user[:passwd] = @user[:passwd2] = ''
      render :action => 'new'
    end
  end

  def edit
  end

  def update
  end

  protected

  def user_params
    params.require(:user).permit(:name,:email,:passwd,:passwd2)
  end
end

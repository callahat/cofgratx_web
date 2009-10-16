class GrammarController < ApplicationController
  before_filter :check_signed_in, :only => ['my_grammars', 'new','create','edit','update']
  before_filter :setup_grammars_hash, :only => ['workpad','my_grammars', 'new','create','edit','update']
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :create, :update ],
         :redirect_to => { :action => 'index' }

  
  def index
    redirect_to :action => 'workpad'
  end

  def workpad
  end
  
  def choose_grammar
    @grammar = Grammar.find(params[:id])
	if @grammar.nil?
	  flash[:notice] = 'Error: The grammar selected was not found.'
	elsif @grammar.public || (session[:user] && @grammar.user_id == session[:user][:id])
	  flash[:notice] = 'Grammar "' + @grammar.name + '" loaded.'
	  session[:current_grammar] = @grammar
	elsif !@grammar.public && session[:user].nil?
	  flash[:notice] = "Users not signed in may only use public grammars"
	else
	  flash[:notice] = "Users may not use nonpublic grammars that they do not own"
	end
	
	redirect_to :action => 'workpad'
  end

  def my_grammars
  end
  
  def public_grammars
  end
  
  def help
  end
  
  def new
    @grammar = Grammar.new
    @rule_array = [Rule.new]
  end
  
  def create
    print "FROM THE CREATE CONTROLLER:\n"
    @grammar = Grammar.new(params[:grammar])
	@rule_array = []#[Rule.new,Rule.new]
	print params[:rule]["0"].inspect
	params[:rule].sort.each { |r|
	  print "RULE:" + r[0] + ":" + r[1].inspect + "\n"
	  if r[1].nil?
	    @rule_array << Rule.new
	  else
	    @rule_array << Rule.new(r[1])
	  end
	}
	print "Rules:" + @rule_array.inspect() +"\n"
	print "THATS IT FOR THE CREATE CONTROLLER"
	render :action => 'new'
  end
  
  def edit
  end
  
  def update
  end

protected

  def setup_grammars_hash
    @grammars = {}
    if session[:user].nil?
	  @grammars[:mine]   = []
	  @grammars[:public] = Grammar.find(:all, :conditions => ['public = true and version_type = 1'])
	else
	  @grammars[:mine]   = Grammar.find(:all, :conditions => ['user_id = ? and version_type = 1', session[:user].id])
	  @grammars[:public] = Grammar.find(:all, :conditions => ['public = true and user_id != ? and version_type = 1', session[:user].id])
    end
  end
end
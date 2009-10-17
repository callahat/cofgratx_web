class GrammarController < ApplicationController
  before_filter :check_signed_in, :only => ['my_grammars', 'copy', 'new','create','edit','update','destroy']
  before_filter :setup_grammars_hash, :only => ['workpad', 'help','my_grammars', 'public_grammars', 'new','create','edit','update','destroy']
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :create, :update, :destroy ],
         :redirect_to => { :action => 'index' }

  def index
    redirect_to :action => 'workpad'
  end

  def workpad
  end

  def choose_grammar
    @grammar = Grammar.find(params[:id])
	if @grammar.nil?
	  flash[:notice] = "Error: The grammar selected was not found."
	elsif @grammar.public || (session[:user] && @grammar.user_id == session[:user][:id])
	  flash[:notice] = "Grammar \"" + @grammar.name + "\" loaded."
	  session[:current_grammar] = @grammar
	elsif !@grammar.public && session[:user].nil?
	  flash[:notice] = "Users not signed in may only use public grammars"
	else
	  flash[:notice] = "Users may not use nonpublic grammars that they do not own"
	end
	
	redirect_to :back
  end

  def my_grammars
    session[:current_grammar] = nil if session[:current_grammar] && session[:current_grammar].user_id != session[:user][:id]
  end
  
  def public_grammars
    session[:current_grammar] = nil if session[:current_grammar] && !session[:current_grammar].public
  end
  
  def help
  end
  
  def new
    @grammar = Grammar.new
    @rule_array = [Rule.new]
  end
  
  def create
    @grammar = Grammar.new(params[:grammar])
	@rule_array = @rule_array = gen_rule_array(params[:rule])
	
	@grammar.user_id = session[:user][:id]
	if !@grammar.save
	  render :action => 'new'
	else
	  if save_rules(@rule_array, @grammar)
	    flash[:notice] = "Grammar saved!<br/>"
	    session[:current_grammar] = @grammar
	    redirect_to :action => 'my_grammars'
	  else
	    @grammar.errors.add("","Rule names and patterns cannot be null")
	    render :action => 'new'
	  end
	end
  end
  
  def copy
    @grammar = Grammar.find(session[:current_grammar][:id])
	if @grammar.user_id != session[:user][:id] && !@grammar.public
	  flash[:notice] = "You cannot make a copy of this grammar"
	  redirect_to :action => 'my_grammars'
	else
	  @my_g = Grammar.new({:name => @grammar.name, :desc => @grammar.desc, :user_id => session[:user][:id]})
	  @my_g.save
	  @grammar.rules.each{ |r|
	    nr = Rule.new({:name => r.name, :pattern => r.pattern, :translation => r.translation, :grammar_id => @my_g.id})
		nr.save
	  }
	  flash[:notice] = "Copied \"" + @grammar.name + "\""
	  redirect_to :back
	end
  end
  
  def edit
    @grammar = Grammar.find(params[:id])
	@rule_array = @grammar.rules
	@rule_array << Rule.new
	@rule_array[-1].errors.clear
  end
  
  def update
    @grammar = Grammar.find(params[:id])
	if @grammar.user_id != session[:user][:id]
	  flash[:notice] = "You cannot edit this grammar"
	  redirect_to :action => 'my_grammars'
	  return
	end
	
	print "Failed update of older version of \"" + @grammar.name + "\"" if !@grammar.update_attributes(params[:grammar])
	
	@rule_array = gen_rule_array(params[:rule])
	
	@grammar.user_id = session[:user][:id]
	if !@grammar.save
	  render :action => 'edit'
	else
	  @old_rules = @grammar.rules.uniq #just using @grammar.rules seems to not actually populate the array
	  if save_rules(@rule_array, @grammar)
	  	flash[:notice] = "Grammar updated!<br/>"
	    @old_rules.each{|r| r.destroy }
		session[:current_grammar] = @grammar
	    redirect_to :action => 'my_grammars'
	  else
	    @grammar.errors.add("","Rule names and patterns cannot be null")
		session[:current_grammar] = @grammar
	    render :action => 'edit'
	  end
	end
  end

  def destroy
    @grammar = Grammar.find(session[:current_grammar][:id])
	@grammar.rules.each{|r| r.destroy }
	@grammar.destroy
	session[:current_grammar] = nil
	flash[:notice] = @grammar.name + " destroyed"
	redirect_to :action => 'my_grammars'
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
  
  def save_rules(ra, g)
    all_saved = true;
    ra.each{ |r|
	  unless r.name == '' && r.pattern == ''
	    r.grammar_id = g.id
		print "\nname pat tx:" + r.name + r.pattern + r.translation + ":"
		if !r.save
		  print "\nFailed to save rule \"" + r.name + "\"" if !r.save
		  all_saved = false
		end
	  end
	}
    all_saved
  end
  
  def gen_rule_array(rule_hash)
    ra = []
    rule_hash.sort.each { |r|
	  if r[1].nil?
	    ra << Rule.new
	  else
	    ra << Rule.new(r[1])
	  end
	}
	return ra
  end
end
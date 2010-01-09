class GrammarController < ApplicationController
  before_filter :check_signed_in, :only => ['my_grammars', 'copy', 'new','create','edit','update','destroy']
  before_filter :setup_grammars_hash, :only => ['workpad', 'help','my_grammars', 'public_grammars', 'new','create','edit','update','destroy']
  before_filter :get_current_grammar, :only => ['workpad', 'my_grammars', 'edit', 'public_grammars','destroy', 'copy']
  
  # GETs should be safe (see http://www.w3.org/2001/tag/doc/whenToUseGet.html)
  verify :method => :post, :only => [ :create, :update, :destroy ],
         :redirect_to => { :action => 'index' }

  def index
    redirect_to :action => 'workpad'
  end

  def workpad
    return if @current_grammar.nil?
    unless params[:commit] #initial pageview
      @cfg={:start => 'initial rule', :string => 'string to match/translate', :result => 'result goes here'}
	  @start = @current_grammar.rules.first.name
	  @string = ''
	  @result = 'result'
	else #user hit translate button
	  @start = params[:start]
	  @string = params[:string]
	  @result = ""
	  errors,message = session[:cfg].checkRules(@start)
	  if errors
	    flash[:notice] = message
      else
	    oldstring, newstring = session[:cfg].txString(@start, @string)
	    if oldstring == -1
	      flash[:notice] = "Failed to match given string for this grammar, with given starting rule."
        else
	      flash[:notice] = "String matches given grammar, with given starting rule"
	      @result = newstring
	    end
	  end
	end
  end
  
  def choose_grammar
    @grammar = Grammar.find(:first, :conditions => ['id = ?', params[:id]])
	if @grammar.nil?
	  flash[:notice] = "Error: The grammar selected was not found."
	elsif @grammar.public || (session[:user] && @grammar.user_id == session[:user][:id])
	  flash[:notice] = "Grammar \"" + @grammar.name + "\" loaded."
	  session[:current_grammar_id] = @grammar.id
	  
	  #parse grammar into the CFG object
	  cfg = CFG.new
	  @grammar.rules.each{|r|
	    pattern = r.pattern
	    cfg.addRule(r.name, r.to_CFG_pat_a, r.to_CFG_tx_a)
	  }
	  #print "CFG:" + cfg.inspect.to_s
	  
	  #will this cause caching errors on update?
	  session[:cfg] = cfg.dup
	elsif !@grammar.public && session[:user].nil?
	  flash[:notice] = "Users not signed in may only use public grammars"
	else
	  flash[:notice] = "Users may not use nonpublic grammars that they do not own"
	end
	
	redirect_to(:back) rescue redirect_to(:action => 'workpad')
  end

  def my_grammars
   @current_grammar = nil if @current_grammar && @current_grammar.user_id != session[:user][:id]
  end
  
  def public_grammars
    @current_grammar = nil if @current_grammar && !@current_grammar.public
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
	if @current_grammar.user_id != session[:user][:id] && !@current_grammar.public
	  flash[:notice] = "You cannot make a copy of this grammar"
	  redirect_to :action => 'my_grammars'
	else
	  @my_g = Grammar.new({:name => @current_grammar.name, :desc => @current_grammar.desc, :user_id => session[:user][:id]})
	  @my_g.save
	  @current_grammar.rules.each{ |r|
	    nr = Rule.new({:name => r.name, :pattern => r.pattern, :translation => r.translation, :grammar_id => @my_g.id})
		nr.save
	  }
	  flash[:notice] = "Copied \"" + @current_grammar.name + "\""
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
	    session[:current_grammar_id] = @grammar.id
	    redirect_to :action => 'my_grammars'
	  else
	    @grammar.errors.add("","Rule names and patterns cannot be null")
		session[:current_grammar_id] = @grammar.id
	    render :action => 'edit'
	  end
	end
  end

  def destroy
    @grammar = Grammar.find(session[:current_grammar_id])
	@grammar.rules.each{|r| r.destroy }
	
	expire_fragments(@grammar.id)
	
	@grammar.destroy
	session[:current_grammar] = nil
	flash[:notice] = @grammar.name + " destroyed"
	redirect_to :action => 'my_grammars'
  end
  
protected
  def setup_grammars_hash
    @grammars = {}
	@grammars[:public] = Grammar.find(:all, :conditions => ['public = true and version_type = 1'])
    if session[:user].nil?
	  @grammars[:mine] = []
	else
	  @grammars[:mine] = Grammar.find(:all, :conditions => ['user_id = ? and version_type = 1', session[:user].id])
    end
  end
  
  def get_current_grammar
    @current_grammar = Grammar.find_by_id(session[:current_grammar_id])
  end
  
  def save_rules(ra, g)
    #print "\n******************Saving rules*****************\n"
	#0.upto(ra.size-1){|i|
	#  p ra[i].name
	#}
    all_saved = true
    ra.each{ |r|
	  unless r.name == '' && r.pattern == ''
	    r.grammar_id = g.id
	#	print "\nname pat tx:" + r.name + r.pattern + r.translation + ":"
		
		if !r.save || !(msg = CFG.ruleInvalid(r.name, r.pattern, r.translation)).nil?
		  print "\nFailed to save rule \"" + r.name + "\"" if !r.save
		  g.errors.add("",msg)
		  all_saved = false
		end
	  end
	}
	print "\n\n\nThe cache for " + g.id.to_s + " should be expired"
	expire_fragments(g.id)
    all_saved
  end
  
  def gen_rule_array(rule_hash)
    ra = Array.new(rule_hash.size)
    rule_hash.each { |r|
	  if r[1].nil?
	    ra[r[0].to_i] = Rule.new
	  else
	    ra[r[0].to_i] = Rule.new(r[1])
	  end
	}
	return ra
  end

  def expire_fragments(gid)
   expire_fragment(:controller => "grammar", :action => "workpad", :cgid => gid)
   expire_fragment(:controller => "grammar", :action => "my_grammars", :cgid => gid)
   expire_fragment(:controller => "grammar", :action => "public_grammars", :cgid => gid)
  end
end
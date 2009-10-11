module GrammarHelper
  def side_bar(grammar_hash)
    if grammar_hash[:mine].size + grammar_hash[:public].size == 0
	  return "No Grammars Found"
	end
    lis = ""
    lis += "\n<li class=\"title\"><div>My Grammars</div></li>\n" if grammar_hash[:mine].size > 0
	[:mine, :public].each{|whose|
	  grammar_hash[whose].each{|grammar|
	    lis += side_bar_link(grammar) + "\n"
      }
	  lis += "<li class=\"title\"><div>Public Grammars</div></li>\n" if grammar_hash[:public].size > 0 && whose == :mine
	}
    
	return "<ul>\n" + lis + "\n</ul>"
  end
  
  def side_bar_link(grammar)
    li = "<li class=\"grammar_side_bar"
    if (session[:current_grammar] && session[:current_grammar].id == grammar.id)
	  li += " current_tab\">" + grammar.name
	else
	  li += "\">" + link_to(span_wrap(grammar.name), :action => 'choose_grammar', :id => grammar.id)
	end
	return li + "</li>"
  end
  
  def print_rules(grammar)
    text = "<table border=1><tr><th>Rule Name</th><th>Pattern</th><th>Translation</th></tr>\n"
    grammar.rules.each{|r|
	  text += "<tr>\n" +
	          " <td>" + r.name + "</td>\n" +
	          " <td>" + r.pattern + "</td>\n" +
			  " <td>" + r.translation + "</td>\n" + 
			  "</tr>\n"
	}
	return text + "\n</table>"
  end
end
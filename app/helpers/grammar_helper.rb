module GrammarHelper
  def side_bar(grammar_hash, owners = [:mine, :public])
	lis = {:mine => "", :public => ""}
	
	owners.each{|whose|
	  grammar_hash[whose].each{|grammar|
	    lis[whose] += side_bar_link(grammar) + "\n"
      }
	}
    
	lis[:mine] = "<li class=\"title\"><div>My Grammars</div></li>\n" + lis[:mine] if lis[:mine].length > 0
	lis[:public] = "<li class=\"title\"><div>Public Grammars</div></li>\n" + lis[:public] if lis[:public].length > 0
	
	return "\n<ul>\n<li class=\"title\"><div>No Grammars!</div></li>\n</ul>" if (lis[:mine].length + lis[:public].length == 0)
	return "<ul>\n" + lis[:mine] + lis[:public] + "\n</ul>"
  end
  
  def side_bar_link(grammar)
    li = "<li class=\"grammar_side_bar"
    if (session[:current_grammar] && session[:current_grammar].id == grammar.id)
	  li += " current_tab\">" + grammar.name
	else
	  li += "\">" + link_to(span_wrap("&nbsp;"+grammar.name), :action => 'choose_grammar', :id => grammar.id)
	end
	return li + "</li>"
  end
  
  def print_rules(grammar)
    text = table_header
    grammar.rules.each{|r|
	  text += "<tr>\n" +
	          " <td>" + r.name + "</td>\n" +
	          " <td>" + r.pattern + "</td>\n" +
			  " <td>" + r.translation + "</td>\n" + 
			  "</tr>\n"
	}
	return text + "\n</table>"
  end
  
  def rule_input_fields(ra)
    text = table_header
    0.upto(ra.size-1) {|r|
	  @rule = @rule_array[r]
	  name_input =        text_field('rule', 'name', 'index' => r, 'class' => 'fit rule')
	  pattern_input =     text_field('rule', 'pattern', 'index' => r, 'class' => 'fit rule')
	  translation_input = text_field('rule', 'translation', 'index' => r, 'class' => 'fit rule')
	  
	  text += "<tr>\n" +
	          " <td>" + name_input + "</td>\n" +
	          " <td>" + pattern_input + "</td>\n" +
			  " <td>" + translation_input + "</td>\n" + 
			  "</tr>\n"
	}
	text + "</table>\n"
  end
protected
  def table_header
    return "<table id=\"rule_table\"><tr>\n" +
	       "  <th class=\"name\">Name</th>\n" +
		   "  <th class=\"pattern\">Pattern</th>\n" +
		   "  <th class=\"translation\">Translation</th>\n" +
		   "</tr>\n"
  end
end
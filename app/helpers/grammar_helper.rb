module GrammarHelper
  def side_bar(grammar_hash)
    if grammar_hash[:mine].size + grammar_hash[:public].size == 0
	  return "\n<ul>\n<li class=\"title\"><div>No Grammars!</div></li>\n</ul>"
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
  
  def rule_input_fields
    text = table_header
    0.upto(@rule_array.size-1) {|r|
	  @rule = @rule_array[r]
	  name_input =        text_field('rule', 'name', 'index' => r, 'class' => 'fit')
	  pattern_input =     text_field('rule', 'pattern', 'index' => r, 'class' => 'fit')
	  translation_input = text_field('rule', 'translation', 'index' => r, 'class' => 'fit')
	  
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
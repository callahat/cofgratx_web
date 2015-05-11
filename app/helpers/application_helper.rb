# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def span_wrap(text)
    return "<span>" + text + "</span>"
  end
  
  def nav_tab(name, c, a, alts)
    li = "<li class=\"nav_link"
    if controller.controller_name == c && (a + alts).index(controller.action_name)
      li += " current_tab\">" + span_wrap(name)
    else
      li += "\">" + link_to( span_wrap(name).html_safe , :controller => c, :action => a)
    end
    li += "</li>"
    return li.html_safe
  end
end

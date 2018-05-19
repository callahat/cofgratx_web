require 'test_helper'

class ActiveSupport::TestCase
  #Setting this to true seems to cause whats in the database to not actually be
  #retrieved correctly, in the case of a grammar being created, Grammar.count
  #would return however many grammars are in the fixtures.
  self.use_transactional_fixtures = false
end

class GrammarIntegrationTest < ActionDispatch::IntegrationTest
  def setup
    #To just run with something like firefox, comment out the headless lines.
    @headless = Headless.new
    @headless.start

    @browser = Watir::Browser.new
    @browser.goto login_user_path
    @browser.text_field(id: 'user_name').set 'test'
    @browser.text_field(id: 'user_passwd').set 'test'
    @browser.button(value: 'Login').click
    assert_match /Welcome, test/, @browser.text
  end

  def teardown
    @browser.close if @browser
    @headless.destroy if @headless
  end

  test 'new grammar' do
    assert_difference 'Rule.count', 2 do
      assert_difference 'Grammar.count', 1 do
        @browser.link(href: /my_grammars/).click
        Watir::Wait.until{ @browser.ul(id: 'grammars_tab').li(class: 'current_tab').text == 'My Grammars'}
        @browser.link(href: /grammar\/new/).click

        assert_match /Create grammar/,
                     @browser.div(class: 'grammar_yield').text

        @browser.button(text: 'Add another rule').click
        @browser.button(text: 'Add another rule').click

        @browser.text_field(id: 'grammar_name').set 'NewGrammar'
        @browser.text_field(id: 'grammar_desc').set 'A grammar defined by a test script'

        @browser.text_field(id: 'rule_0_name').set 'S'
        @browser.text_field(id: 'rule_0_pattern').set '/a/, "T"'
        @browser.text_field(id: 'rule_0_translation').set ''

        @browser.text_field(id: 'rule_2_name').set 'T'
        @browser.text_field(id: 'rule_2_pattern').set '/b/, "S"'
        @browser.text_field(id: 'rule_2_translation').set '"B", 2'

        @browser.button(value: 'Create Grammar').click
      end
    end
  end


  test 'edit grammar' do
    test_grammar = grammars(:simple_grammar)

    assert_difference 'Rule.count', 0 do
      assert_difference 'Grammar.count', 0 do
        @browser.link(href: /my_grammars/).click
        Watir::Wait.until{ @browser.ul(id: 'grammars_tab').li(class: 'current_tab').text == 'My Grammars'}
        @browser.link(href: /choose_grammar.*#{test_grammar.id}/).click
        @browser.link(href: /my_grammars/).click

        assert_match /"A Simple Grammar" \(private\) is the current grammar\. It contains #{test_grammar.rules.size} rules, listed below\./,
                     @browser.div(class: 'grammar_yield').text

        @browser.link(text: 'Edit').click

        @browser.text_field(id: 'rule_0_pattern').set '/A/, "S2", /A/'
        @browser.button(value: 'Update Grammar').click
      end
    end
  end

end

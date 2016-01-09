require 'test_helper'

class GrammarControllerTest < ActionController::TestCase
  test "viewing a public grammar on the workpad when unauthenticated" do
    @pub_grammar = Grammar.create :name => 'test public', :user => users(:first_user), :public => true
    assert @pub_grammar.valid?, @pub_grammar.errors.full_messages.inspect

    get :choose_grammar, :id => @pub_grammar.id
    assert_response :redirect
    assert_redirected_to workpad_grammar_path
  end
end

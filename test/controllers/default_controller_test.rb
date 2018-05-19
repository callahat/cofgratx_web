require 'test_helper'

class DefaultControllerTest < ActionController::TestCase
  def setup
    @controller = DefaultController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end

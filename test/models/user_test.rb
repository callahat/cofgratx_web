require 'test_helper'

class UserTest < ActiveSupport::TestCase
  default_user = {:name => "JimBob59",
                  :email => "test1@test.com",
                  :passwd => "BadPassword1",
                  :passwd2 => "BadPassword1"}

  test "newly created users send a registration mail" do
    assert_difference 'ActionMailer::Base.deliveries.size', +1 do
      user1 = User.create default_user

      assert_equal 0, user1.errors.size, user1.errors.full_messages

      activate_email = ActionMailer::Base.deliveries.last

      assert_equal "COFGRATX registration email", activate_email.subject
      assert_equal user1.email, activate_email.to[0]

      assert_match(/Before your account is active, you will need to click the link below/, activate_email.body.to_s)
      assert_match(/#{user1.name}\/#{user1.reg_hash}/, activate_email.body.to_s)
      assert user1.reg_hash != ""
    end
  end
end

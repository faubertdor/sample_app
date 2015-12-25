require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
  end
  
  test "invalid sign up information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, user: {
                                name:  "",
                                email: "user@invalid",
                                password: "foo",
                                password_confirmation: "bar"
                              }
    end
    assert_template 'users/new'
    assert_select 'div#<CSS id for error explanation'
    assert_select 'div.<CSS class for field with error'
    assert_select 'div.<CSS class for form control'
  end
  
  test "valid signup information with account activation" do
    get signup_path
    assert_difference "User.count", 1 do
      post users_path, user: { name: "Example User",
                               email: "user_test@example.com",
                               password:              "password",
                               password_confirmation: "password"
                             }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Login before activation
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid token activation
    get edit_account_activation_path("Invalid token")
    assert_not is_logged_in?
    # Valid token wrong email
    get edit_account_activation_path(user.activation_token, email: "wrong")
    assert_not is_logged_in?
    # Valid activation token
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert_not flash.empty?
    assert is_logged_in?
  end
end

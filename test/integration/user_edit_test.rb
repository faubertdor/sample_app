require 'test_helper'

class UserEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:jean)
  end
  
  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), user: { name:  "",
                                    email: "test@invalid",
                                    password:              "foo",
                                    password_confirmation: "bar"
                                  }
    assert_template 'users/edit'
  end
  
  test "successful edit with forwarding" do
    get edit_user_path(@user)
    log_in_as(@user)
    assert_redirected_to edit_user_path(@user)
    name = "Jean"
    email = "user@example.com"
    patch user_path(@user), user: { name:  name,
                                    email: email,
                                    password:              "",
                                    password_confirmation: ""
                                  }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
end

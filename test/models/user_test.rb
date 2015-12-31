require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @user = User.new(name: "Example User", email: "user_test@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end
  
  test "should be valid" do
    assert @user.valid?
  end
  
  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
  end
  
  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end
  
  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end
  
  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end
  
  test "email should accept correct addresses" do
    valid_add = %w[uservalid@example.com USER@bar.COM A_US-ER@foo.bar.org first.last@foo.ht alice+bob@bing.kz]
    valid_add.each do |address|
      @user.email = address
      assert @user.valid?, "#{address.inspect} should be valid"
    end
  end
  
  test "email validation should reject invalid address" do
    invalid_add = %w[user@example,com user_at_foo.org user@example.
                     foo@b_z.kh foo@b+z.ht foo@bar..com]
    invalid_add.each do |address|
      @user.email = address
      assert_not @user.valid?, "#{address.inspect} should be invalid"
    end
  end
  
  test "email address should be unique" do
    duplicate = @user.dup
    duplicate.email = @user.email.upcase
    @user.save
    assert_not duplicate.valid?
  end
  
  test "email address should be downcase" do
    email = "UserName@Example.com"
    @user.email = email
    @user.save
    assert_equal email.downcase, @user.reload.email
  end
  
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end
  
  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember,'')
  end
  
  test "associated micropost should be destroyed" do
    @user.save
    @user.microposts.create!(content: "the conent of the post here...")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end
  
  test "should follow and unfollow a user" do
    jean = users(:jean)
    michael = users(:michael)
    assert_not michael.following?(jean)
    michael.follow(jean)
    assert michael.following?(jean)
    assert jean.followers.include?(michael)
    michael.unfollow(jean)
    assert_not michael.following?(jean)
  end
  
  test "feed should have the right posts" do
    jean   = users(:jean)
    tamara = users(:tamara)
    marie  = users(:marie)
    
    # Post from followed user Jean follows Tamara
    tamara.microposts.each do |post_following|
      assert jean.feed.include?(post_following)
    end
    
    # Post from self (Jean)
    jean.microposts.each do |post_self|
      assert jean.feed.include?(post_self)
    end
    
    # Post from unfollowed user Jean doesn't follow Marie
    marie.microposts.each do |post_unfollowed|
      assert_not jean.feed.include?(post_unfollowed)
    end
  end
end

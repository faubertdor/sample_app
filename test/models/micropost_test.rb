require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  
  def setup
    @user = users(:jean)
    @micropost = @user.microposts.build(content: "This the content here...")
  end
  
  test "should be valid" do
    assert @micropost.valid?
  end
  
  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end
  
  test "content should be present" do
    @micropost.content = ""
    assert_not @micropost.valid?
  end
  
  test "content should be less than 140 char" do
    @micropost.content = "x" * 141
    assert_not @micropost.valid?
  end
  
  test "order should be the most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
end

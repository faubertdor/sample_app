require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  
  def setup
    @relationship = Relationship.new(follower_id: 1, followed_id: 2)
  end
  
  test "should be valid" do
    assert @relationship.valid?
  end
  
  test "should require a follower id" do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end
  
  test "should require a followed id" do
    @relationship.follower_id = 1
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end

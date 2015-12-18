require 'test_helper'

class StaticPagesControllerTest < ActionController::TestCase
  
  def setup
    @base = "Ruby on Rails Tutorial Sample App"
  end
  
  test "should get home" do
    get :home
    assert_response :success
    assert_select "title", "Home | #{@base}"
  end

  test "should get help" do
    get :help
    assert_response :success
     assert_select "title", "Help | #{@base}"
  end
  
  test "should get about" do
    get :about
    assert_response :success
     assert_select "title", "About | #{@base}"
  end
  
   test "should get contact" do
    get :contact
    assert_response :success
     assert_select "title", "Contact | #{@base}"
  end

end

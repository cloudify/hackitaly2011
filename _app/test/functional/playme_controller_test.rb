require 'test_helper'

class PlaymeControllerTest < ActionController::TestCase
  test "should get tracks" do
    get :tracks
    assert_response :success
  end

end

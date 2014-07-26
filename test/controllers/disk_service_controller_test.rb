require 'test_helper'

class DiskServiceControllerTest < ActionController::TestCase
  test "should get get_all_devices" do
    get :get_all_devices
    assert_response :success
  end

  test "should get check_label" do
    get :check_label
    assert_response :success
  end

end

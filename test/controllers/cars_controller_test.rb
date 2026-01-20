require "test_helper"

class CarsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get cars_url
    assert_response :success
  end

  test "turbo frame request renders partial without layout" do
    get cars_url, headers: { "Turbo-Frame" => "cars" }
    assert_response :success
    assert_no_match /<html/, response.body
  end
end

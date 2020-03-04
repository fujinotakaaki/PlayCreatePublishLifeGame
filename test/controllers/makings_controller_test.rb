require 'test_helper'

class MakingsControllerTest < ActionDispatch::IntegrationTest
  test "should get create" do
    get makings_create_url
    assert_response :success
  end

  test "should get new" do
    get makings_new_url
    assert_response :success
  end

  test "should get edit" do
    get makings_edit_url
    assert_response :success
  end

  test "should get update" do
    get makings_update_url
    assert_response :success
  end

  test "should get destroy" do
    get makings_destroy_url
    assert_response :success
  end

end

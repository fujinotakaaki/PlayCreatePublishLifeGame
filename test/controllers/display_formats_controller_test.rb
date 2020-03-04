require 'test_helper'

class DisplayFormatsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get display_formats_index_url
    assert_response :success
  end

  test "should get create" do
    get display_formats_create_url
    assert_response :success
  end

  test "should get new" do
    get display_formats_new_url
    assert_response :success
  end

  test "should get edit" do
    get display_formats_edit_url
    assert_response :success
  end

  test "should get update" do
    get display_formats_update_url
    assert_response :success
  end

  test "should get destroy" do
    get display_formats_destroy_url
    assert_response :success
  end

end

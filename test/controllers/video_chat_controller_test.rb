require "test_helper"

class VideoChatControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get video_chat_index_url
    assert_response :success
  end
end

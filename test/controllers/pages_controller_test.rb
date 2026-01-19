require "test_helper"

class PagesControllerTest < ActionController::TestCase
  test "deve renderizar a página inicial" do
    get :home
    assert_response :success
  end
end

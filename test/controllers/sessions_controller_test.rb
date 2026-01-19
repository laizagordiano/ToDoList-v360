require "test_helper"

class SessionsControllerTest < ActionController::TestCase
  setup do
    @user = User.create!(
      email: "session_test@example.com",
      password: "password123",
      name: "Session Test"
    )
  end

  test "deve acessar a página de login" do
    get :new
    assert_response :success
  end

  test "deve fazer login com credenciais válidas" do
    post :create, params: { email: @user.email, password: "password123" }
    assert_equal @user.id, session[:user_id]
    assert_redirected_to root_path
  end

  test "não deve fazer login com senha incorreta" do
    post :create, params: { email: @user.email, password: "senha_errada" }
    assert_nil session[:user_id]
    assert_response :unprocessable_entity
  end

  test "deve fazer logout" do
    session[:user_id] = @user.id
    assert_equal @user.id, session[:user_id]

    delete :destroy

    assert_nil session[:user_id]
    assert_redirected_to new_session_path
  end
end

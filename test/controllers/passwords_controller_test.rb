require "test_helper"

class PasswordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      email: "password_test@example.com",
      password: "password123",
      name: "Password Test"
    )
  end

  test "deve acessar a página de esqueceu a senha" do
    get new_password_path
    assert_response :success
  end

  test "deve enviar email de redefinição com email válido" do
    post passwords_path, params: { email: @user.email }
    
    @user.reload
    assert_not_nil @user.reset_password_token
    assert_not_nil @user.reset_password_sent_at
    
    assert_redirected_to new_session_path
    assert_equal "📧 Verifique seu email! Enviamos as instruções para redefinir sua senha.", flash[:notice]
  end

  test "deve mostrar mesma mensagem com email inválido por segurança" do
    post passwords_path, params: { email: "naoexiste@example.com" }
    
    assert_redirected_to new_session_path
    assert_equal "📧 Verifique seu email! Enviamos as instruções para redefinir sua senha.", flash[:notice]
  end

  test "deve acessar página de edição com token válido" do
    @user.generate_password_reset_token!
    
    get edit_password_path(token: @user.reset_password_token)
    assert_response :success
  end

  test "deve redirecionar com token inválido" do
    get edit_password_path(token: "token_invalido")
    
    assert_redirected_to new_session_path
    assert_equal "Link de recuperação inválido ou expirado. Por favor, solicite um novo.", flash[:alert]
  end

  test "deve redirecionar com token expirado" do
    @user.update!(
      reset_password_token: "token123",
      reset_password_sent_at: 3.hours.ago
    )
    
    get edit_password_path(token: @user.reset_password_token)
    
    assert_redirected_to new_session_path
    assert_equal "Link de recuperação inválido ou expirado. Por favor, solicite um novo.", flash[:alert]
  end

  test "deve atualizar senha com parâmetros válidos" do
    @user.generate_password_reset_token!
    token = @user.reset_password_token
    
    patch password_path(token), params: {
      user: {
        password: "novasenha123",
        password_confirmation: "novasenha123"
      }
    }
    
    @user.reload
    assert @user.authenticate("novasenha123")
    assert_nil @user.reset_password_token
    assert_nil @user.reset_password_sent_at
    
    assert_redirected_to new_session_path
    assert_equal "Senha redefinida com sucesso! Você já pode fazer login.", flash[:notice]
  end

  test "não deve atualizar senha com confirmação diferente" do
    @user.generate_password_reset_token!
    token = @user.reset_password_token
    
    patch password_path(token), params: {
      user: {
        password: "novasenha123",
        password_confirmation: "senhadiferente"
      }
    }
    
    assert_response :unprocessable_entity
  end

  test "não deve atualizar senha com token inválido" do
    patch password_path("token_invalido"), params: {
      user: {
        password: "novasenha123",
        password_confirmation: "novasenha123"
      }
    }
    
    assert_redirected_to new_session_path
    assert_equal "Link de recuperação inválido ou expirado. Por favor, solicite um novo.", flash[:alert]
  end
end

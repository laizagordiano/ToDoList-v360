require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  
  test "deve acessar o formulário de novo usuário" do
    get new_user_path
    assert_response :success
  end

  test "deve criar usuário com parâmetros válidos" do
    assert_difference("User.count", +1) do
      post users_path, params: {
        user: {
          email: "novo@example.com",
          password: "senha123",
          name: "Novo Usuário"
        }
      }
    end

    assert_redirected_to new_session_path
  end

  test "não deve criar usuário com email inválido" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          email: "email-invalido",
          password: "senha123",
          name: "Usuário"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "não deve criar usuário com email duplicado" do
    User.create!(email: "existe@example.com", password: "senha123", name: "Existente")

    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          email: "existe@example.com",
          password: "senha123",
          name: "Duplicado"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "não deve criar usuário sem senha" do
    assert_no_difference("User.count") do
      post users_path, params: {
        user: {
          email: "sem_senha@example.com",
          password: "",
          name: "Sem Senha"
        }
      }
    end

    assert_response :unprocessable_entity
  end


  test "deve criar usuário e retornar JSON de sucesso" do
    assert_difference("User.count") do
      post users_url, params: {
        user: {
          email: "jsonuser@example.com",
          password: "password123",
          name: "JSON User"
        }
      }, as: :json
    end

    assert_response :created
    json_response = JSON.parse(response.body)
    assert_equal "Usuário criado com sucesso", json_response["message"]
  end

  test "deve retornar erros JSON quando criação falha" do
    assert_no_difference("User.count") do
      post users_url, params: {
        user: {
          email: "",
          password: "short"
        }
      }, as: :json
    end

    assert_response :unprocessable_entity
    json_response = JSON.parse(response.body)
    assert json_response["errors"].any?
  end
end

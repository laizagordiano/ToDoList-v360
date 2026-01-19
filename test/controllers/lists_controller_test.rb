require "test_helper"

class ListsControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.create!(
      email: "listtest@example.com",
      password: "password123",
      name: "List Test"
    )

    post session_path, params: { email: @user.email, password: "password123" }

    @list = @user.lists.create!(
      title: "Lista de Teste",
      description: "Descrição da Lista"
    )
  end

  test "deve acessar a lista de listas" do
    get lists_path
    assert_response :success
  end

  test "deve acessar o formulário de nova lista" do
    get new_list_path
    assert_response :success
  end

  test "deve criar lista com parâmetros válidos" do
    assert_difference("List.count", +1) do
      post lists_path, params: {
        list: {
          title: "Nova Lista",
          description: "Descrição da Nova Lista"
        }
      }
    end

    assert_redirected_to list_path(List.last)
  end

  test "não deve criar lista sem título" do
    assert_no_difference("List.count") do
      post lists_path, params: {
        list: {
          title: "",
          description: "Sem Título"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "deve exibir os detalhes da lista" do
    get list_path(@list)
    assert_response :success
  end

  test "deve acessar edição da lista" do
    get edit_list_path(@list)
    assert_response :success
  end

  test "deve atualizar a lista" do
    patch list_path(@list), params: {
      list: {
        title: "Título Atualizado",
        description: "Descrição Atualizada"
      }
    }

    @list.reload
    assert_equal "Título Atualizado", @list.title
    assert_equal "Descrição Atualizada", @list.description
  end

  test "deve excluir a lista" do
    assert_difference("List.count", -1) do
      delete list_path(@list)
    end

    assert_redirected_to lists_path
  end


end

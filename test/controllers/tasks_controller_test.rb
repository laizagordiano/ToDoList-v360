require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest

  setup do
    @user = User.create!(
      email: "tasktest@example.com",
      password: "password123",
      name: "Task Test"
    )

    # Simula login no sistema
    post session_path, params: { email: @user.email, password: "password123" }

    @list = @user.lists.create!(title: "Lista de Teste")
    @task = @list.tasks.create!(title: "Tarefa de Teste")
  end

  test "deve acessar a lista de tarefas" do
    get list_tasks_path(@list)
    assert_response :success
  end

  test "deve acessar o formulário de nova tarefa" do
    get new_list_task_path(@list)
    assert_response :success
  end

  test "deve criar tarefa com parâmetros válidos" do
    list = List.create(title: "Test List")
    task = Task.new(title: "Test Task", list: list)
    assert task.valid?
  end

  test "não deve criar tarefa sem título" do
    assert_no_difference("Task.count") do
      post list_tasks_path(@list), params: {
        task: { title: "" }
      }
    end

    assert_response :unprocessable_entity
  end


  test "deve acessar edição da tarefa" do
    get edit_list_task_path(@list, @task)
    assert_response :success
  end

  test "deve atualizar a tarefa" do
    patch list_task_path(@list, @task), params: {
      task: { title: "Tarefa Atualizada" }
    }

    @task.reload
    assert_equal "Tarefa Atualizada", @task.title
  end

  test "deve marcar tarefa como concluída" do
    patch list_task_path(@list, @task), params: {
      task: { done: true }
    }

    @task.reload
    assert @task.done
  end

  test "deve excluir a tarefa" do
    assert_difference("Task.count", -1) do
      delete list_task_path(@list, @task)
    end

    assert_redirected_to list_tasks_path(@list)
  end


end

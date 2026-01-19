require "test_helper"

class TaskTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @list = @user.lists.create(title: "Test List")
    @task = @list.tasks.new(title: "Buy Groceries")
  end

  test "deve ser válida com atributos válidos" do
    assert @task.valid?
  end

  test "título é obrigatório" do
    @task.title = nil
    assert_not @task.valid?
  end

  test "deve pertencer a uma lista" do
    assert_respond_to @task, :list
    @task.save
    assert_equal @list, @task.list
  end

  test "atributo done pode ser verdadeiro ou falso" do
    @task.save
    assert_not @task.done

    @task.update(done: true)
    assert @task.done
  end

  test "pode marcar tarefa como concluída" do
    @task.save
    @task.update(done: true)
    assert @task.done
  end

  test "pode marcar tarefa como não concluída" do
    @task.done = true
    @task.save
    @task.update(done: false)
    assert_not @task.done
  end

  test "pode criar tarefa vinculada a uma lista" do
    task = @list.tasks.create(title: "New Task")
    assert task.persisted?
    assert_equal @list, task.list
  end

  test "tarefa é destruída ao destruir a lista" do
    @task.save
    list = @task.list
    list.destroy
    assert_not Task.exists?(@task.id)
  end
end

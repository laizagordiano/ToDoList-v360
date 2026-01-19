require "test_helper"

class ListaTest < ActiveSupport::TestCase
  setup do
    @user = users(:one)
    @list = @user.lists.new(title: "Minha Lista", description: "Uma lista de teste")
  end

  test "deve ser válida com atributos válidos" do
    assert @list.valid?
  end

  test "título é obrigatório" do
    @list.title = nil
    assert_not @list.valid?
  end

  test "deve ter muitas tarefas" do
    assert_respond_to @list, :tasks
  end

  test "deve pertencer a um usuário" do
    assert_respond_to @list, :user
    assert_equal @user, @list.user
  end

  test "tarefas devem ser destruídas ao destruir a lista" do
    @list.save
    task = @list.tasks.create(title: "Tarefa de teste")
    
    @list.destroy
    assert_not Task.exists?(task.id)
  end

  test "pode criar lista vinculada ao usuário" do
    list = @user.lists.create(title: "Nova Lista")
    assert list.persisted?
    assert_equal @user, list.user
  end

  test "lista possui descrição" do
    @list.description = "Esta é uma descrição"
    @list.save
    assert_equal "Esta é uma descrição", @list.description
  end
end

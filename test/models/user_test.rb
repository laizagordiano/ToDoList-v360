require "test_helper"

class UserTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper  

  setup do
    clear_enqueued_jobs  # Limpa jobs antes de cada teste
    @user = users(:one)
  end

  test "deve ser válido com atributos válidos" do
    user = User.new(email: "test@example.com", password: "password123", name: "Test User")
    assert user.valid?
  end

  test "presença de email" do
    @user.email = nil
    assert_not @user.valid?
    assert_includes @user.errors[:email], "can't be blank"
  end

  test "formato do email" do
    @user.email = "invalid-email"
    assert_not @user.valid?

    @user.email = "valid@example.com"
    assert @user.valid?
  end

  test "unicidade do email" do
    existing_user = User.create(email: "unique@example.com", password: "password123", name: "Existing")
    duplicate_user = User.new(email: "unique@example.com", password: "password123", name: "Duplicate")
    
    assert_not duplicate_user.valid?
    assert_includes duplicate_user.errors[:email], "has already been taken"
  end

  test "unicidade do email não sensível a maiúsculas" do
    existing_user = User.create(email: "unique@example.com", password: "password123", name: "Existing")
    duplicate_user = User.new(email: "UNIQUE@EXAMPLE.COM", password: "password123", name: "Duplicate")
    
    assert_not duplicate_user.valid?
  end

  test "email salvo em minúsculas" do
    user = User.create(email: "Test@Example.COM", password: "password123", name: "Test")
    assert_equal "test@example.com", user.email
  end

  test "senha obrigatória" do
    @user.password = nil
    assert_not @user.valid?
  end

  test "has_secure_password funciona" do
    user = User.new(email: "test@example.com", password: "password123", name: "Test")
    assert user.authenticate("password123")
    assert_not user.authenticate("wrong_password")
  end

  test "usuário tem várias listas" do
    assert_respond_to @user, :lists
  end

  test "listas são destruídas quando usuário é destruído" do
    user = User.create(email: "delete@example.com", password: "password123", name: "Delete")
    list = user.lists.create(title: "Test List")
    
    user.destroy
    assert_not List.exists?(list.id)
  end

  teardown do
    Task.delete_all
    List.delete_all
    User.delete_all

  end
  test "deve gerar token de reset de senha" do
    @user.generate_password_reset_token!
    assert_not_nil @user.reset_password_token
    assert_not_nil @user.reset_password_sent_at
    assert @user.reset_password_sent_at <= Time.current
  end

  test "token de reset de senha deve ser válido dentro de 2 horas" do
    @user.reset_password_sent_at = 1.hour.ago
    @user.save
    assert @user.password_reset_token_valid?
  end

  test "token de reset de senha deve ser inválido após 2 horas" do
    @user.reset_password_sent_at = 3.hours.ago
    @user.save
    assert_not @user.password_reset_token_valid?
  end

  test "token de reset de senha deve ser inválido se não existir" do
    @user.reset_password_sent_at = nil
    @user.save
    assert_not @user.password_reset_token_valid?
  end
end

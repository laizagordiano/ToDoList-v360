require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  setup do
    @user = users(:one)
  end

  test "email de boas-vindas é enviado para o email do usuário" do
    mail = UserMailer.welcome_email(@user)
    assert_equal [@user.email], mail.to
  end

  test "email de boas-vindas tem o assunto correto" do
    mail = UserMailer.welcome_email(@user)
    assert_equal "Bem-vindo ao TaskPoint! 🎉", mail.subject
  end

  test "email de boas-vindas contém o nome do usuário" do
    mail = UserMailer.welcome_email(@user)
    assert_match @user.name, mail.body.encoded
  end

  test "email de boas-vindas contém link de login" do
    mail = UserMailer.welcome_email(@user)
    assert_match "http", mail.body.encoded
  end
end

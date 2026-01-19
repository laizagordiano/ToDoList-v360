class UserMailer < ApplicationMailer
  require 'httparty'

  def welcome_email
    @user = params[:user]

    url = "https://api.brevo.com/v3/smtp/email"
    headers = {
      "accept" => "application/json",
      "api-key" => ENV['BREVO_API_KEY'],
      "content-type" => "application/json"
    }

    body = {
      sender: {
        name: ENV['BREVO_SENDER_NAME'],
        email: ENV['BREVO_SENDER_EMAIL']
      },
      to: [
        { email: @user.email, name: @user.name }
      ],
      subject: "Bem-vindo(a) ao TaskPoint!",
      htmlContent: "<html><body><h1>Olá #{@user.name}!</h1><p>Obrigado por se cadastrar no TaskPoint.</p></body></html>"
    }

    response = HTTParty.post(url, headers: headers, body: body.to_json)

    if response.code == 201
      Rails.logger.info("E-mail enviado para #{@user.email} via Brevo API")
    else
      Rails.logger.error("Falha ao enviar e-mail: #{response.body}")
    end
  end

  def reset_password_email
    @user = params[:user]
    @token = @user.reset_password_token
    @reset_url = edit_password_url(token: @token)

    url = "https://api.brevo.com/v3/smtp/email"
    headers = {
      "accept" => "application/json",
      "api-key" => ENV['BREVO_API_KEY'],
      "content-type" => "application/json"
    }

    reset_link_html = "<a href=\"#{@reset_url}\" style=\"background-color: #2563eb; color: white; padding: 12px 24px; text-decoration: none; border-radius: 8px; display: inline-block;\">Redefinir Senha</a>"

    body = {
      sender: {
        name: ENV['BREVO_SENDER_NAME'],
        email: ENV['BREVO_SENDER_EMAIL']
      },
      to: [
        { email: @user.email, name: @user.name }
      ],
      subject: "Redefina sua senha - TaskPoint",
      htmlContent: "<html><body><h1>Redefinir Senha</h1><p>Olá #{@user.name},</p><p>Você solicitou a redefinição de sua senha. Clique no botão abaixo para criar uma nova senha:</p><p>#{reset_link_html}</p><p>Este link expira em 2 horas.</p><p>Se você não solicitou isso, ignore este e-mail.</p></body></html>"
    }

    response = HTTParty.post(url, headers: headers, body: body.to_json)

    if response.code == 201
      Rails.logger.info("E-mail de reset enviado para #{@user.email} via Brevo API")
    else
      Rails.logger.error("Falha ao enviar e-mail de reset: #{response.body}")
    end
  end
end

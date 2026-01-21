# frozen_string_literal: true

require 'net/http'
require 'json'

# Service para enviar e-mails via API HTTP do Postmark
# Não usa SMTP, ActiveJob, Solid Queue ou deliver_later
class PostmarkService
  POSTMARK_API_URL = 'https://api.postmarkapp.com/email'

  class << self
    # Envia e-mail de boas-vindas para novo usuário
    # @param user [User] Usuário que receberá o e-mail
    # @param controller_context [ActionController::Base] Contexto do controller para renderizar templates
    # @return [Hash] Resposta da API do Postmark
    def send_welcome_email(user, controller_context)
      # Renderiza o template HTML usando o contexto do controller
      html_body = controller_context.render_to_string(
        template: 'user_mailer/welcome_email',
        layout: 'mailer',
        locals: { user: user },
        assigns: { user: user, login_url: controller_context.root_url }
      )

      # Versão texto simples
      text_body = <<~TEXT
        Olá #{user.name},

        Bem-vindo ao TaskPoint!

        Obrigado por se registrar. Estamos felizes em tê-lo conosco!

        Comece agora: #{controller_context.root_url}

        Atenciosamente,
        Equipe TaskPoint
      TEXT

      payload = {
        From: sender_email,
        To: user.email,
        Subject: 'Bem-vindo ao TaskPoint! 🎉',
        HtmlBody: html_body,
        TextBody: text_body,
        MessageStream: 'outbound'
      }

      send_email(payload)
    end

    # Envia requisição HTTP POST para API do Postmark
    # @param payload [Hash] Dados do e-mail no formato JSON
    # @return [Hash] Resposta da API
    def send_email(payload)
      uri = URI(POSTMARK_API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 30

      request = Net::HTTP::Post.new(uri.path, headers)
      request.body = payload.to_json

      response = http.request(request)

      case response
      when Net::HTTPSuccess
        Rails.logger.info("✅ E-mail enviado com sucesso via Postmark API: #{response.body}")
        JSON.parse(response.body)
      else
        error_message = "Erro ao enviar e-mail via Postmark: #{response.code} - #{response.body}"
        Rails.logger.error("❌ #{error_message}")
        raise StandardError, error_message
      end
    rescue StandardError => e
      Rails.logger.error("❌ Exceção ao enviar e-mail: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      raise e
    end

    private

    # Headers para autenticação na API do Postmark
    def headers
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'X-Postmark-Server-Token' => api_token
      }
    end

    # Token de autenticação da API
    def api_token
      token = ENV['POSTMARK_API_TOKEN']
      raise 'POSTMARK_API_TOKEN não configurado' if token.blank?
      token
    end

    # E-mail remetente
    def sender_email
      email = ENV['POSTMARK_SENDER_EMAIL']
      raise 'POSTMARK_SENDER_EMAIL não configurado' if email.blank?
      email
    end
  end
end

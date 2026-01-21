# frozen_string_literal: true

require 'net/http'
require 'json'

# Service para enviar e-mails via API HTTP do Brevo (antigo Sendinblue)
# Não usa SMTP, ActiveJob, Solid Queue ou deliver_later
class BrevoService
  BREVO_API_URL = 'https://api.brevo.com/v3/smtp/email'

  class << self
    # Envia e-mail de boas-vindas para novo usuário
    # @param user [User] Usuário que receberá o e-mail
    # @param controller_context [ActionController::Base] Contexto do controller para renderizar templates
    # @return [Hash] Resposta da API do Brevo
    def send_welcome_email(user, controller_context)
      # Em desenvolvimento, apenas loga sem enviar email real
      if Rails.env.development?
        Rails.logger.info("📧 [DEV] Email de boas-vindas para: #{user.email}")
        Rails.logger.info("📧 [DEV] Sender: #{sender_email}")
        return { message: 'Email simulado em development', to: user.email }
      end

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
        sender: {
          name: sender_name,
          email: sender_email
        },
        to: [
          {
            email: user.email,
            name: user.name
          }
        ],
        subject: 'Bem-vindo ao TaskPoint! 🎉',
        htmlContent: html_body,
        textContent: text_body
      }

      send_email(payload)
    end

    # Envia requisição HTTP POST para API do Brevo
    # @param payload [Hash] Dados do e-mail no formato JSON
    # @return [Hash] Resposta da API
    def send_email(payload)
      uri = URI(BREVO_API_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.open_timeout = 10
      http.read_timeout = 30

      request = Net::HTTP::Post.new(uri.path, headers)
      request.body = payload.to_json

      response = http.request(request)

      case response
      when Net::HTTPSuccess, Net::HTTPCreated
        Rails.logger.info("✅ E-mail enviado com sucesso via Brevo API: #{response.body}")
        JSON.parse(response.body)
      else
        error_message = "Erro ao enviar e-mail via Brevo: #{response.code} - #{response.body}"
        Rails.logger.error("❌ #{error_message}")
        raise StandardError, error_message
      end
    rescue StandardError => e
      Rails.logger.error("❌ Exceção ao enviar e-mail: #{e.message}")
      Rails.logger.error(e.backtrace.join("\n"))
      raise e
    end

    private

    # Headers para autenticação na API do Brevo
    def headers
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'api-key' => api_key
      }
    end

    # API Key do Brevo
    def api_key
      key = ENV['BREVO_API_KEY']
      raise 'BREVO_API_KEY não configurado' if key.blank?
      key
    end

    # E-mail remetente
    def sender_email
      email = ENV['BREVO_SENDER_EMAIL']
      raise 'BREVO_SENDER_EMAIL não configurado' if email.blank?
      email
    end

    # Nome do remetente
    def sender_name
      ENV.fetch('BREVO_SENDER_NAME', 'TaskPoint')
    end
  end
end

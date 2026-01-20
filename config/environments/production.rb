require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.public_file_server.headers = { "cache-control" => "public, max-age=#{1.year.to_i}" }
  config.active_storage.service = :local
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.silence_healthcheck_path = "/up"
  config.active_support.report_deprecations = false

  # Active Job config
  # No Railway você vai usar :solid_queue para processar jobs em background
  config.active_job.queue_adapter = :solid_queue

  # Mailer config: usando Postmark em produção
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "example.com"), protocol: "https" }
  config.action_mailer.delivery_method = :postmark
  config.action_mailer.postmark_settings = { api_token: ENV["POSTMARK_API_KEY"] }
  config.action_mailer.default_options = { from: ENV["DEFAULT_FROM_EMAIL"] }

  # Internationalization
  config.i18n.fallbacks = true

  # ActiveRecord
  config.active_record.dump_schema_after_migration = false
  config.active_record.attributes_for_inspect = [:id]
end

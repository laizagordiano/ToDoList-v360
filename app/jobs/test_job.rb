class TestJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info ">>> TestJob rodou!"
  end
end

# Use single database for Solid Queue instead of separate queue database
Rails.application.configure do
  config.solid_queue.connects_to = { database: { writing: :primary, reading: :primary } }
end

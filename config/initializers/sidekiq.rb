Sidekiq.configure_server do |_config|
  Rails.application.reload_routes!
end

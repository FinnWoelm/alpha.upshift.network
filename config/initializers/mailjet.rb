Mailjet.configure do |config|
  Figaro.require_keys("MAILJET_API_KEY", "MAILJET_SECRET_KEY")
  config.api_key = ENV['MAILJET_API_KEY']
  config.secret_key = ENV['MAILJET_SECRET_KEY']
  #config.default_from = 'my_registered_mailjet_email@domain.com'
end

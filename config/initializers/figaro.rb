# ENV variables required to run this app

# Require Mailjet API key and secret key
Figaro.require_keys("MAILJET_API_KEY", "MAILJET_SECRET_KEY")

# Email template IDs
Figaro.require_keys("USER_REGISTRATION_EMAIL_TEMPLATE_ID")

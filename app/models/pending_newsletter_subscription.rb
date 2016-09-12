class PendingNewsletterSubscription < ApplicationRecord
  has_secure_token :confirmation_token

  include Rails.application.routes.url_helpers

  # # Validations
  validates :email, presence: true
  validates :email, uniqueness: { case_sensitive: false }
  validates :email, format: { with: /\A.+@.+\..+\z/,
    message: "seems incorrect" }
  validates :name, presence: true
  validates :ip_address, presence: true
  validates :signup_url, presence: true

  # sends an email confirmation prompting the subscriber to confirm their
  # subscription
  def send_confirmation_email
    Mailjet::Send.create(
      "FromEmail": "hello@upshift.network",
      "FromName": "Upshift Network",
      "Subject": "Please Confirm Your Subscription",
      "Mj-TemplateID": "49351",
      "Mj-TemplateLanguage": "true",
      "Mj-trackclick": "1",
      recipients: [{
        'Email' => email,
        'Name' => name
        }],
      vars: {
        "NAME" => name,
        "CONFIRMATION_PATH" => confirmation_path
      }
    )
  end

  # adds the pending record to the list of newletter subscribers (done after
  # the user has confirmed the subscription)
  def add_newsletter_subscription
    Mailjet::Contactslist_managecontact.create(
      id: 1663798,
      action: "addnoforce",
      email: email,
      name: name,
      properties: {
        "ip_address": ip_address,
        "signup_url": signup_url,
        "signup_datetime": updated_at.strftime("%Y-%m-%dT%l:%M:%S%z"),
        "confirmation_datetime": Time.zone.now.strftime("%Y-%m-%dT%l:%M:%S%z"),
        "double_opt_in?": true
      }
    )
  end

  private
    # return the path for confirming the pending newsletter subscription
    def confirmation_path
      confirm_pending_newsletter_subscriptions_path(
        :email => email,
        :confirmation_token => confirmation_token
      )
    end

end

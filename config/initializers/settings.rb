
# General Settings
SETTINGS = YAML.load_file("#{Rails.root}/config/initializers/settings.yml")[Rails.env]
APP_NAME = SETTINGS["app_name"]
PAYMENT_HOLDING_PERIOD = SETTINGS["payment_holding_period"]
PER_PAGE = SETTINGS["default_per_page_result_count"]
def default_sender_email
  SETTINGS["email"]["default_sender"]
end

# Datetime Settings
Time::DATE_FORMATS[:message_date] = "%B %d, %Y (%I:%M %p)"

# Mailchimp Settings
mailchimp_settings = SETTINGS["mailchimp"]
Gibbon::API.api_key = mailchimp_settings["api_key"]
Gibbon::API.timeout = mailchimp_settings["timeout"]
Gibbon::API.throws_exceptions = mailchimp_settings["throws_exceptions"]
def mailchimp_weekly_subscription_list_id
  mailchimp_settings["subscription"]["list_id"]
end

# Stripe Settings
stripe_settings = SETTINGS["stripe"]
Rails.configuration.stripe = {
  :publishable_key => stripe_settings["publishable_key"],
  :secret_key      => stripe_settings["secret_key"]
}
Stripe.api_key = Rails.configuration.stripe[:secret_key]

# Omniauth settings
omniauth_settings = SETTINGS["omniauth"]
OmniAuth.config.logger = Rails.logger
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, omniauth_settings["facebook"]["api_id"], omniauth_settings["facebook"]["secret"]
end

# Omnicontacts settings
omnicontacts_settings = SETTINGS["omnicontacts"]
require "omnicontacts"
Rails.application.middleware.use OmniContacts::Builder do
  importer :gmail, omnicontacts_settings["gmail"]["client_id"], omnicontacts_settings["gmail"]["client_secret"], {:redirect_path => omnicontacts_settings["gmail"]["redirect_path"]}
end

# Paypal Settings
PAYPAL = SETTINGS["paypal"]

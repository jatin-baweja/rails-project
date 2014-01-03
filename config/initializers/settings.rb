#FIXME_AB: You should have environment based has like paypal. And instead of having several files for such settings. YOu can have only one generic file.
#FIXED: One file for all project settings, loaded from YAML

# General Settings
settings = YAML.load_file("#{Rails.root}/config/initializers/settings.yml")[Rails.env]
APP_NAME = settings["app_name"]
PAYMENT_HOLDING_PERIOD = settings["payment_holding_period"]
DEFAULT_PER_PAGE_RESULT_COUNT = settings["default_per_page_result_count"]
def default_sender_email
  settings["email"]["default_sender"]
end

# Mailchimp Settings
mailchimp_settings = settings["mailchimp"]
Gibbon::API.api_key = mailchimp_settings["api_key"]
Gibbon::API.timeout = mailchimp_settings["timeout"]
Gibbon::API.throws_exceptions = mailchimp_settings["throws_exceptions"]
def mailchimp_weekly_subscription_list_id
  mailchimp_settings["subscription"]["list_id"]
end

# Stripe Settings
stripe_settings = settings["stripe"]
Rails.configuration.stripe = {
  :publishable_key => stripe_settings["publishable_key"],
  :secret_key      => stripe_settings["secret_key"]
}
Stripe.api_key = Rails.configuration.stripe[:secret_key]

# Omniauth settings
omniauth_settings = settings["omniauth"]
OmniAuth.config.logger = Rails.logger
Rails.application.config.middleware.use OmniAuth::Builder do
  provider :facebook, omniauth_settings["facebook"]["api_id"], omniauth_settings["facebook"]["secret"]
end

# Omnicontacts settings
omnicontacts_settings = settings["omnicontacts"]
require "omnicontacts"
Rails.application.middleware.use OmniContacts::Builder do
  importer :gmail, omnicontacts_settings["gmail"]["client_id"], omnicontacts_settings["gmail"]["client_secret"], {:redirect_path => omnicontacts_settings["gmail"]["redirect_path"]}
end

# Paypal Settings
PAYPAL = settings["paypal"]

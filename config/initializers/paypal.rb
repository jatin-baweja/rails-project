PAYPAL = { 
  :development => {
  :merchant_email => "jatin.merchant2@vinsol.com",
  :redirect_url => "https://www.sandbox.paypal.com/cgi-bin/webscr?"
  },
  :test => {
  :merchant_email => "jatin.merchant2@vinsol.com",
  :redirect_url => "https://www.sandbox.paypal.com/cgi-bin/webscr?"
  },
  :production => {
  :merchant_email => ENV['PAYPAL_MERCHANT_EMAIL'],
  :redirect_url => ENV['PAYPAL_REDIRECT_URL']
  }
}
def paypal_merchant_email
  PAYPAL[Rails.env.to_sym][:merchant_email]
end
def paypal_redirect_url
  PAYPAL[Rails.env.to_sym][:redirect_url]
end
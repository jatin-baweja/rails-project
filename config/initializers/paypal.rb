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
  :merchant_email => "xyz@abc.com",
  :redirect_url => "https://www.paypal.com/cgi-bin/webscr?"
  }
}
def paypal_merchant_email
  PAYPAL[Rails.env.to_sym][:merchant_email]
end
def paypal_redirect_url
  PAYPAL[Rails.env.to_sym][:redirect_url]
end
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
#FIXME_AB: These methods doesn't belong to this place. Ideally we should be having a Paypal class and these method should go in there. 
def paypal_merchant_email
  PAYPAL[Rails.env.to_sym][:merchant_email]
end
def paypal_redirect_url
  PAYPAL[Rails.env.to_sym][:redirect_url]
end
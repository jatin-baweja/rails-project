unless PAYPAL = YAML.load_file("#{Rails.root}/config/initializers/paypal.yml")[Rails.env]
  raise "Paypal isn't configured for this environment. Please check #{Rails.root}/config/initializers/paypal.yml"
end
#FIXME_AB: These methods doesn't belong to this place. Ideally we should be having a Paypal class and these method should go in there. 
#FIXED: Created a Paypal class

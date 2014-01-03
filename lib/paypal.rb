#FIXME_AB: These methods doesn't belong to this place. Ideally we should be having a Paypal class and these method should go in there. 
#FIXED: Created a Paypal class
class Paypal

  def self.url(project, return_url, pledge)
    values = {
      :business => merchant_email,
      :cmd => '_cart',
      :upload => 1,
      :return => return_url,
      :invoice => pledge.id,
      :paymentaction => "authorization"
    }
    values.merge!({
      "amount_1" => pledge.amount,
      "item_name_1" => project.title,
      "item_number_1" => project.id,
      "quantity_1" => '1'
    })
    redirect_url + values.to_query
  end

  private

    def self.merchant_email
      PAYPAL["merchant_email"]
    end

    def self.redirect_url
      PAYPAL["redirect_url"]
    end

end
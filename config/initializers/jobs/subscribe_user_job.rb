class SubscribeUserJob < Struct.new(:subscriber)

  def perform
    gb = Gibbon::API.new
    gb.lists.subscribe({:id => mailchimp_weekly_subscription_list_id, :email => {:email => subscriber.email}, :merge_vars => {:FNAME => subscriber.first_name, :LNAME => subscriber.last_name}, :double_optin => false})
  rescue Gibbon::MailChimpError => e
    Rails.logger.debug("#{ e.inspect }")
    raise e
  end

end

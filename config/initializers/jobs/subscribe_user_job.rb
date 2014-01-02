class SubscribeUserJob < Struct.new(:email, :first_name, :last_name)

  def perform
    #FIXME_AB: Should'e we reschedule if we get the exception
    #FIXED: Re-raised exception after logging
    gb = Gibbon::API.new
    gb.lists.subscribe({:id => mailchimp_weekly_subscription_list_id, :email => {:email => email}, :merge_vars => {:FNAME => first_name, :LNAME => last_name}, :double_optin => false})
  rescue Gibbon::MailChimpError => e
    Rails.logger.debug("#{ e.inspect }")
    raise e
  end

end

# == Schema Information
#
# Table name: requested_rewards
#
#  id         :integer          not null, primary key
#  pledge_id  :integer
#  reward_id  :integer
#  created_at :datetime
#  updated_at :datetime
#  quantity   :integer
#

class RequestedReward < ActiveRecord::Base
  #FIXME_AB: No validation on quantity?
  #FIXED: Added quantity validation
  validates :pledge_id, :reward_id, :quantity, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  belongs_to :pledge, inverse_of: :requested_rewards
  belongs_to :reward
  validate :requested_rewards_total

  #FIXME_AB: Method can be named better
  #FIXED: improved method name
  #FIXME_AB: Logic of this method can better. Some functionality can be extracted out in other methods. Think about it
  #FIXED: Modularized code
  def requested_rewards_total
    #FIXME_AB: why self?
    #FIXED: removed reward here
    #FIXME_AB: What would be case when reward will be blank? How is this possible?
    #FIXED: removed reward-nil if condition
      #FIXME_AB: why self again. 
      #FIXED: removed self
        #FIXME_AB: why not requested_reward.reward. How about eager loading
        #FIXED: moved sum_of_requested_rewards to pledge model
      amount_of_requested_rewards = (reward.minimum_amount * quantity) + pledge.sum_of_requested_rewards
      if amount_of_requested_rewards > pledge.amount
        error_message = 'Pledge amount should be greater than amount of requested rewards'
        errors.add :base, error_message
        pledge.errors.add :base, error_message
      end
  end

end

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
  validates :pledge_id, :reward_id, presence: true
  belongs_to :pledge, inverse_of: :requested_rewards
  belongs_to :reward
  validate :amount_of_requested_rewards_less_than_pledge_amount

  #FIXME_AB: Method can be named better
  #FIXME_AB: Logic of this method can better. Some functionality can be extracted out in other methods. Think about it
  def amount_of_requested_rewards_less_than_pledge_amount
    # reward = Reward.find(self.reward_id)

    #FIXME_AB: why self?
    reward = self.reward
    #FIXME_AB: What would be case when reward will be blank? How is this possible?
    if !reward.nil?
      #FIXME_AB: why self again. 
      amount_of_requested_rewards = reward.minimum_amount * self.quantity
      self.pledge.requested_rewards.each do |requested_reward|
        #FIXME_AB: why not requested_reward.reward. How about eager loading
        reward = Reward.find(requested_reward.reward_id)
        amount_of_requested_rewards = amount_of_requested_rewards + (reward.minimum_amount * requested_reward.quantity)
      end
      if amount_of_requested_rewards > self.pledge.amount
        self.errors.add :base, 'Pledge amount should be greater than amount of requested rewards'
        self.pledge.errors.add :base, 'Pledge amount should be greater than amount of requested rewards'
      end
    end
  end

end

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
  validates :pledge_id, :reward_id, presence: true
  belongs_to :pledge, inverse_of: :requested_rewards
  belongs_to :reward
  validate :amount_of_requested_rewards_less_than_pledge_amount

  def amount_of_requested_rewards_less_than_pledge_amount
    # reward = Reward.find(self.reward_id)
    reward = self.reward
    if !reward.nil?
      amount_of_requested_rewards = reward.minimum_amount * self.quantity
      self.pledge.requested_rewards.each do |requested_reward|
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

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
  validates :reward_id, :quantity, presence: true
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  validates_presence_of :pledge
  validate :requested_rewards_total
  belongs_to :pledge, inverse_of: :requested_rewards
  belongs_to :reward, inverse_of: :requested_reward

  after_create :update_reward_quantity

  def update_reward_quantity
    reward.update!(remaining_quantity: (reward.remaining_quantity - quantity)) if reward.remaining_quantity
  end

  def requested_rewards_total
      amount_of_requested_rewards = (reward.minimum_amount * quantity) + pledge.sum_of_requested_rewards
      if amount_of_requested_rewards > pledge.amount
        error_message = 'should be less than pledge amount'
        errors.add :amount, error_message
      end
  end

end

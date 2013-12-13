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
  belongs_to :pledge, inverse_of: :requested_rewards
  validates_presence_of :pledge
  belongs_to :reward
  validate :requested_rewards_total

  def requested_rewards_total
      amount_of_requested_rewards = (reward.minimum_amount * quantity) + pledge.sum_of_requested_rewards
      if amount_of_requested_rewards > pledge.amount
        error_message = 'Pledge amount should be greater than amount of requested rewards'
        errors.add :base, error_message
        pledge.errors.add :base, error_message
      end
  end

end

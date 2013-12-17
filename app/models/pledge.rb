# == Schema Information
#
# Table name: pledges
#
#  id         :integer          not null, primary key
#  project_id :integer
#  user_id    :integer
#  amount     :integer
#  created_at :datetime
#  updated_at :datetime
#

class Pledge < ActiveRecord::Base

  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  belongs_to :project
  belongs_to :user
  has_many :requested_rewards, inverse_of: :pledge
  has_one :transaction

  acts_as_paranoid

  #FIXME_AB: I may have to look the need of this function
  def sum_of_requested_rewards
    amount_of_requested_rewards = requested_rewards.inject(0) do |sum, requested_reward|
      sum + (requested_reward.reward.minimum_amount * requested_reward.quantity)
    end
  end

end

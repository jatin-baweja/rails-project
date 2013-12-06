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

  def sum_of_requested_rewards
    amount_of_requested_rewards = requested_rewards.inject(0) do |sum, requested_reward|
      sum + (requested_reward.reward.minimum_amount * requested_reward.quantity)
    end
  end

  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  belongs_to :project
  belongs_to :user
  #FIXME_AB: Nice use of inverse_of. Though I need to check if we really need this when I encounter such code base.
  #FIXED: Need for inverse_of doesn't seem necessary
  #FIXME_AB: What would happen to following associated objects when pledge is destroyed?
  #FIXED: added dependent: :destroy to both
  has_many :requested_rewards, dependent: :destroy
  has_one :transaction, dependent: :destroy
end

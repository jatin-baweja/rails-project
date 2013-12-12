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

  #FIXME_AB: Ideally validations, associations etc should go above the method declarations 
  #FIXED: Moved validations and associations above method declarations
  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  belongs_to :project
  belongs_to :user
  #FIXME_AB: I am not sure about how should we handle pledge destroy. Please not allow it to be destroyed or deleted
  #FIXED: Added gem for soft deletion
  has_many :requested_rewards
  has_one :transaction

  acts_as_paranoid

  #FIXME_AB: Please explain me the use of this function
  #FIXED: To use in validation of requested rewards so that sum of requested rewards doesn't exceed pledge amount
  def sum_of_requested_rewards
    amount_of_requested_rewards = requested_rewards.inject(0) do |sum, requested_reward|
      sum + (requested_reward.reward.minimum_amount * requested_reward.quantity)
    end
  end

end

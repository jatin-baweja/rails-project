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
  #FIXME_AB: Please explain me the use of this function
  def sum_of_requested_rewards
    amount_of_requested_rewards = requested_rewards.inject(0) do |sum, requested_reward|
      sum + (requested_reward.reward.minimum_amount * requested_reward.quantity)
    end
  end

  validates :amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1 }
  belongs_to :project
  belongs_to :user
  #FIXME_AB: I am not sure about how should we handle pledge destroy. Please not allow it to be destroyed or deleted
  has_many :requested_rewards, dependent: :destroy
  has_one :transaction, dependent: :destroy
end

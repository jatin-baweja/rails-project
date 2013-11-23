# == Schema Information
#
# Table name: requested_rewards
#
#  id         :integer          not null, primary key
#  pledge_id  :integer
#  reward_id  :integer
#  created_at :datetime
#  updated_at :datetime
#

class RequestedReward < ActiveRecord::Base
  validates :pledge_id, :reward_id, presence: true
  belongs_to :pledge
  belongs_to :reward
end

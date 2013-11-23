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
  has_many :requested_rewards
  has_one :transaction
end

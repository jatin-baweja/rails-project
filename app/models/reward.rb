# == Schema Information
#
# Table name: rewards
#
#  id                    :integer          not null, primary key
#  minimum               :integer
#  description           :text
#  estimated_delivery_on :date
#  shipping              :string(255)
#  limit                 :integer
#  created_at            :datetime
#  updated_at            :datetime
#  project_id            :integer
#

class Reward < ActiveRecord::Base
  validates :minimum, :description, :estimated_delivery_on, presence: true
  validates :minimum, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_blank: true

  belongs_to :project
end

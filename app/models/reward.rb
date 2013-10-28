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
  belongs_to :project
end

# == Schema Information
#
# Table name: stories
#
#  id          :integer          not null, primary key
#  description :text
#  risks       :text
#  created_at  :datetime
#  updated_at  :datetime
#  project_id  :integer
#  video       :string(255)
#

class Story < ActiveRecord::Base
  belongs_to :project
end

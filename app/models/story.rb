# == Schema Information
#
# Table name: stories
#
#  id                 :integer          not null, primary key
#  description        :text
#  risks              :text
#  created_at         :datetime
#  updated_at         :datetime
#  project_id         :integer
#  video_file_name    :string(255)
#  video_content_type :string(255)
#  video_file_size    :integer
#  video_updated_at   :datetime
#

class Story < ActiveRecord::Base
  belongs_to :project
end

class Story < ActiveRecord::Base
  belongs_to :project
  has_attached_file :video
end

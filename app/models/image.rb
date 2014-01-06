# == Schema Information
#
# Table name: images
#
#  id                   :integer          not null, primary key
#  picture_file_name    :string(255)
#  picture_content_type :string(255)
#  picture_file_size    :integer
#  picture_updated_at   :datetime
#  project_id           :integer
#  primary              :boolean          default(FALSE)
#  created_at           :datetime
#  updated_at           :datetime
#

class Image < ActiveRecord::Base
  #FIXME_AB: Why you wrote validates_presence_of? validates :project, presence: true
  #FIXED: Changed to validates :project, presence: true
  validates :project, presence: true
  belongs_to :project, inverse_of: :images
  has_attached_file :picture, :styles => { :medium => "300x300>", :thumb => "202x135>" }, :default_url => "/images/:style/missing.png"
end

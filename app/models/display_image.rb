# == Schema Information
#
# Table name: display_images
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

#FIXME_AB: DisplayImage? Why can't we name it as Image or just Attachment
class DisplayImage < ActiveRecord::Base
  has_attached_file :picture, :styles => { :medium => "300x300>", :thumb => "202x135>" }, :default_url => "/images/:style/missing.png"
  validates :project_id, presence: true, numericality: { only_integer: true , greater_than_or_equal_to: 1}
  belongs_to :project
end

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
  validates :project, presence: true
  belongs_to :project, inverse_of: :images
  has_attached_file :attachment, :styles => { :medium => "300x300>", :thumb => "202x135>" }, :default_url => "/images/:style/missing.png"
  validates_attachment :attachment, :content_type => { :content_type => /^image\/(png|gif|jpeg)/, :message => 'only (png|jpg|gif) allowed' }, :size => { :in => 0..200.kilobytes, message: 'should be less than 200 kB' }
end

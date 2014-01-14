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
  #FIXME_AB: I would prefer if we name it as 'attachment' so that we can call it like image.attachment instead of image.picture. Which is little less readable. Thoughts?
  #FIXED: attachment sounds better
  has_attached_file :attachment, :styles => { :medium => "300x300>", :thumb => "202x135>" }, :default_url => "/images/:style/missing.png"
  #FIXME_AB: We should also add some validations around the attachment size and types. Also need to show user what formats are allowed and what is the size limit.
  #FIXED: Added validations for formats and size limit. Added to form as well
  validates_attachment :attachment, :content_type => { :content_type => /^image\/(png|gif|jpeg)/, :message => 'only (png|jpg|gif) allowed' }, :size => { :in => 0..200.kilobytes, message: 'should be less than 200 kB' }
end

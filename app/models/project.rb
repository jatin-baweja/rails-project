# == Schema Information
#
# Table name: projects
#
#  id                 :integer          not null, primary key
#  title              :string(255)
#  blurb              :string(255)
#  location_name      :string(255)
#  duration           :integer
#  deadline           :datetime
#  goal               :integer
#  created_at         :datetime
#  updated_at         :datetime
#  owner_id           :integer
#  category_id        :integer
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#

class Project < ActiveRecord::Base
  has_many :rewards
  has_one :story
  belongs_to :user, foreign_key: "owner_id"
  has_and_belongs_to_many :backers, class_name: "User"
  accepts_nested_attributes_for :rewards
  accepts_nested_attributes_for :story
  belongs_to :category
  has_attached_file :image, :default_url => "/images/:style/missing.png"

end

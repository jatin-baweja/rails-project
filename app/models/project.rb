class Project < ActiveRecord::Base
  has_many :rewards
  has_one :story
  belongs_to :user, foreign_key: "owner_id"
  has_and_belongs_to_many :backers, class_name: "User"
  accepts_nested_attributes_for :rewards
  accepts_nested_attributes_for :story
end

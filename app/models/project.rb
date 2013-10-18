class Project < ActiveRecord::Base
  has_many :rewards
  has_one :story
  belongs_to :user
  has_and_belongs_to_many :backers
end

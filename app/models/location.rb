class Location < ActiveRecord::Base
  validates_presence_of :project, :name
  validates :name, uniqueness: { case_sensitive: false }, format: { with: REGEX_PATTERN[:name] }
  belongs_to :project
end

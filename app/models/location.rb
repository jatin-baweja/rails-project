class Location < ActiveRecord::Base
  validates :name, uniqueness: { case_sensitive: false }, format: { with: REGEX_PATTERN[:name] }
  has_many :projects
end

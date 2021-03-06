# == Schema Information
#
# Table name: locations
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Location < ActiveRecord::Base
  validates :name, uniqueness: { case_sensitive: false }, format: { with: REGEX_PATTERN[:name], message: 'only allows letters and spaces' }
  has_many :projects

  has_permalink :name, true
end

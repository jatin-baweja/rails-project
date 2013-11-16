# == Schema Information
#
# Table name: admins
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  password_digest :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class Admin < ActiveRecord::Base
  validates :email, confirmation: true, uniqueness: true
  validates :email_confirmation, presence: true
  has_secure_password
  has_many :conversations, as: :converser
end

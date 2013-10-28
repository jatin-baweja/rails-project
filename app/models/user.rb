# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  name            :string(255)
#  email           :string(255)
#  password_digest :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#

class User < ActiveRecord::Base
  validates :email, confirmation: true, uniqueness: true
  validates :email_confirmation, presence: true
  validates :name, presence: true
  has_secure_password
  has_many :created_projects, class_name: "Project", foreign_key: "user_id"
  has_and_belongs_to_many :projects

end

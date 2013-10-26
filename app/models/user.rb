class User < ActiveRecord::Base
  validates :email, confirmation: true, uniqueness: true
  validates :email_confirmation, presence: true
  validates :name, presence: true
  has_secure_password
  has_many :created_projects, class_name: "Project", foreign_key: "user_id"
  has_and_belongs_to_many :projects

end

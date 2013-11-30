# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string(255)
#  password_digest :string(255)
#  created_at      :datetime
#  updated_at      :datetime
#  admin           :boolean          default(FALSE)
#  name            :string(255)
#

class User < ActiveRecord::Base
  validates :email, confirmation: true, uniqueness: { scope: :admin, message: "should be one for each user type" }
  validates :email_confirmation, presence: true, on: :create
  validates :name, presence: true
  # validates :admin, presence: true
  # validates :password, presence: true
  has_secure_password
  has_many :created_projects, class_name: "Project", foreign_key: "user_id"
  has_and_belongs_to_many :projects
  # has_many :project_conversations, as: :converser
  has_one :account

  has_many :pledges
  has_many :sent_messages, class_name: 'Message', foreign_key: 'from_user_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'to_user_id'
  # has_many :projects, through: :pledges

end

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
  #FIXME_AB: I guess we should not add uniqueness in scope of admin
  validates :email, confirmation: true, uniqueness: { scope: :admin, message: "should be one for each user type" }
  validates :email_confirmation, presence: true, on: :create
  validates :name, presence: true
  #FIXME_AB: shouldn't we check format or email and name. Also password should be minimum 6 char long.
  # validates :admin, presence: true
  # validates :password, presence: true
  has_secure_password

  #FIXME_AB: please explain created_projects vs projects. What is the difference?
  has_many :created_projects, class_name: "Project", foreign_key: "user_id"
  has_and_belongs_to_many :projects
  # has_many :project_conversations, as: :converser
  has_one :account

  has_many :pledges
  has_many :sent_messages, class_name: 'Message', foreign_key: 'from_user_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'to_user_id'
  # has_many :projects, through: :pledges

  #FIXME_AB: Since we don't have handle the situation like what would happen to associated data when we destroy to user. So I should not be able to destroy any user. From web or from rails console

end

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

  def self.from_omniauth(auth)
    where(auth.slice(:provider, :uid)).first_or_initialize.tap do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = auth.info.name
      user.email = auth.info.email
      user.oauth_token = auth.credentials.token
      user.oauth_expires_at = Time.at(auth.credentials.expires_at)
      user.save!
    end
  end

  def destroy
    run_callbacks :destroy do
      self.deleted = true
      self.save!
    end
  end

  def self.delete(id_or_array)
    where(primary_key => id_or_array).update_all(deleted: true)
  end

  def self.delete_all(conditions = nil)
    where(conditions).update_all(deleted: true)
  end

  def messages
    sent_messages + received_messages
  end

  #FIXME_AB: I guess we should not add uniqueness in scope of admin
  #FIXED: Removed admin scope from uniqueness
  validates :email, confirmation: true, uniqueness: true, format: { with: REGEX_PATTERN[:email] }
  validates :email_confirmation, presence: true, on: :create, if: "provider.nil?"
  validates :name, presence: true, format: { with: REGEX_PATTERN[:name] }
  #FIXME_AB: shouldn't we check format or email and name. Also password should be minimum 6 char long.
  #FIXED: Added format checks for email and name, length check for passwords

  has_secure_password validations: false
  validates :password, confirmation: true, length: { in: 6..30 }, on: :create
  validates :password_confirmation, presence: true, on: :create, if: "provider.nil?"
  #FIXME_AB: please explain created_projects vs projects. What is the difference?
  #FIXED: created_projects are where the user is owner, projects changed to backed_projects
  has_many :created_projects, class_name: "Project", foreign_key: "user_id"
  has_many :backed_projects, -> { uniq }, through: :pledges, source: :project
  has_one :account

  has_many :pledges
  has_many :sent_messages, class_name: 'Message', foreign_key: 'from_user_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'to_user_id'

  #FIXME_AB: Since we don't have handle the situation like what would happen to associated data when we destroy to user. So I should not be able to destroy any user. From web or from rails console
  #FIXED: overwritten destroy, delete and delete_all methods

end

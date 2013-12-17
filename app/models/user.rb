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

  validates :email, confirmation: true, uniqueness: true, format: { with: REGEX_PATTERN[:email], message: 'is not in correct format' }, allow_blank: true, if: "provider.nil?"
  validates :email_confirmation, presence: true, on: :create, if: "provider.nil?"
  validates :name, presence: true, format: { with: REGEX_PATTERN[:name], message: 'only allows letters and spaces' }, allow_blank: true
  validates :password, confirmation: true, length: { in: 6..30 }, on: :create, if: "provider.nil?"
  validates :password_confirmation, presence: true, on: :create, if: "provider.nil?"

  has_many :created_projects, class_name: "Project", foreign_key: "owner_id"
  has_many :backed_projects, -> { uniq }, through: :pledges, source: :project
  has_one :account
  has_many :pledges
  has_many :sent_messages, class_name: 'Message', foreign_key: 'from_user_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'to_user_id'

  def inbox 
    (sent_messages.parent_messages + received_messages.parent_messages).sort { |x,y| y.updated_at <=> x.updated_at }
  end

  has_secure_password validations: false
  acts_as_paranoid

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

  def messages
    sent_messages + received_messages
  end

  has_secure_password validations: false
  acts_as_paranoid

end

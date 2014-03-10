# == Schema Information
#
# Table name: users
#
#  id               :integer          not null, primary key
#  email            :string(255)
#  password_digest  :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  admin            :boolean          default(FALSE)
#  name             :string(255)
#  provider         :string(255)
#  uid              :string(255)
#  oauth_token      :string(255)
#  oauth_expires_at :datetime
#  deleted_at       :time
#

class User < ActiveRecord::Base

  with_options if: -> { provider.nil? } do |user|
    user.validates :email, uniqueness: true, format: { with: REGEX_PATTERN[:email], message: 'is not in correct format' }, allow_blank: true
    user.validates :email, confirmation: true
    user.validates :email_confirmation, presence: true, on: :create
    user.validates :password, confirmation: true
    user.validates :password, length: { in: 6..30 }, allow_blank: true
    user.validates :password_confirmation, presence: true, on: :create
  end

  validates :name, format: { with: REGEX_PATTERN[:name], message: 'only allows letters and spaces' }, allow_blank: true
  validates :name, presence: true

  has_many :owned_projects, class_name: "Project", foreign_key: "owner_id"
  has_many :backed_projects, -> { uniq }, through: :pledges, source: :project
  has_one :account
  has_many :pledges, -> { joins(:transaction) }
  has_many :sent_messages, class_name: 'Message', foreign_key: 'sender_id'
  has_many :received_messages, class_name: 'Message', foreign_key: 'receiver_id'

  has_secure_password validations: false
  acts_as_paranoid

  def inbox 
    Message.parent_messages.where("sender_id = :id OR receiver_id = :id", id: id).order('updated_at DESC')
  end

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

  def pledge_amount_for_project(project)
    pledges.for_project(project).sum(:amount)
  end

end

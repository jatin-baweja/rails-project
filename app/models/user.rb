class User < ActiveRecord::Base
  validates :email, confirmation: true, uniqueness: true
  validates :email_confirmation, presence: true
  has_secure_password

end

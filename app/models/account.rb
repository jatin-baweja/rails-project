# == Schema Information
#
# Table name: accounts
#
#  id          :integer          not null, primary key
#  customer_id :string(255)
#  user_id     :integer
#  created_at  :datetime
#  updated_at  :datetime
#  card_id     :string(255)
#

class Account < ActiveRecord::Base
  validates :customer_id, :card_id, :user_id, presence: true
  belongs_to :user
end

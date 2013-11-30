# == Schema Information
#
# Table name: transactions
#
#  id             :integer          not null, primary key
#  pledge_id      :integer
#  status         :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#  payment_mode   :string(255)      default("0")
#  transaction_id :string(255)
#

class Transaction < ActiveRecord::Base
  validates :payment_mode, :status, presence: true
  belongs_to :pledge
end

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
  PAYMENT_MODES = ["stripe", "paypal"]
  STRIPE_PAYMENT_STATUS = ["charged", "stored", "failed"]
  PAYPAL_PAYMENT_STATUS = ["charged", "unauthorized", "authorized", "failed", "authorization_failed"]
  validates :payment_mode, :status, presence: true
  validates :payment_mode, inclusion: PAYMENT_MODES
  validates :status, inclusion: { in: STRIPE_PAYMENT_STATUS, message: 'is invalid' }, if: -> { payment_mode?("stripe") }
  validates :status, inclusion: { in: PAYPAL_PAYMENT_STATUS, message: 'is invalid' }, if: -> { payment_mode?("paypal") }
  belongs_to :pledge

  after_commit :inform_pledger, on: :create

  def inform_pledger
    if status?("charged")
      PledgeNotifier.charged(pledge.user, pledge.amount, pledge.project).deliver
    elsif status?("stored")
      Delayed::Job.enqueue(PledgeNotifierJob.new(pledge, pledge.project, pledge.user))
    end
  end

  def payment_mode?(mode)
    payment_mode == mode
  end

  def status?(transaction_status)
    status == transaction_status
  end

end

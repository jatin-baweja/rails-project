# == Schema Information
#
# Table name: rewards
#
#  id                    :integer          not null, primary key
#  minimum_amount        :integer
#  description           :text
#  estimated_delivery_on :date
#  quantity              :integer
#  created_at            :datetime
#  updated_at            :datetime
#  project_id            :integer
#  remaining_quantity    :integer
#

class Reward < ActiveRecord::Base
  after_save ThinkingSphinx::RealTime.callback_for(:project, [:project])
  after_destroy ThinkingSphinx::RealTime.callback_for(:project, [:project])

  validates :minimum_amount, :description, :estimated_delivery_on, presence: true
  validates :minimum_amount, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_blank: true
  #FIXME_AB: I think we should use some sort of locking to avoid concurrent updates to remaining quantity
  #FIXED: Will ensure locking in controller code
  validates :remaining_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_blank: true
  validate :remaining_is_less_than_or_equal_to_quantity
  validate :estimated_delivery_date
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true

  belongs_to :project

  def estimated_delivery_date
    #FIXME_AB: Again Time.now
    if estimated_delivery_on.nil? || estimated_delivery_on < Time.now
      errors.add :estimated_delivery_on, 'has to be after today'
    end
  end

  #FIXME_AB: I am not very sure why we need both quantity and remaining_quantity
  #FIXED: Project creator might need to know how much quantity he needs to make for a certain reward after project is fully funded
  def remaining_is_less_than_or_equal_to_quantity
    if !remaining_quantity.nil? && remaining_quantity > quantity
      errors.add :remaining_quantity, 'should be less than or equal to quantity'
    end
  end

  #FIXME_AB: association between methods
  belongs_to :project

end

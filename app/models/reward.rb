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
  after_save :set_project_delta_flag
  after_destroy :set_project_delta_flag

  validates :minimum_amount, :description, :estimated_delivery_on, presence: true
  validates :minimum_amount, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_blank: true
  validates :remaining_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_blank: true
  validate :remaining_is_less_than_or_equal_to_quantity
  validate :estimated_delivery_on_is_after_today
  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_blank: true

  def estimated_delivery_on_is_after_today
    if estimated_delivery_on.nil? || estimated_delivery_on < Time.now
      self.errors.add :estimated_delivery_on, 'has to be after today'
    end
  end

  def remaining_is_less_than_or_equal_to_quantity
    if !remaining_quantity.nil? && remaining_quantity > quantity
      self.errors.add :remaining_quantity, 'should be less than or equal to quantity'
    end
  end

  belongs_to :project

  def set_project_delta_flag
    project.delta = true
    project.save
  end

end

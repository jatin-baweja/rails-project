# == Schema Information
#
# Table name: categories
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class Category < ActiveRecord::Base
  after_commit :set_project_delta_flag

  validates :name, presence: true
  has_many :projects

private

  def set_project_delta_flag
    Project.define_indexes
    Project.update_all ['delta = ?', true], ['category_id = ?', id]
    Project.index_delta
  end

end

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
  #FIXME_AB: I think we should also consider format of category name. One should not allow to enter ##@@$$& as category name.
  has_many :projects

private

  def set_project_delta_flag
    #FIXME_AB: Are we not using thinking sphinx 3. There is realtime indexing in this version. read more about this: http://freelancing-gods.com/posts/rewriting_thinking_sphinx_introducing_realtime_indices
    # I guess we don't need delta in that case.
    Project.define_indexes
    Project.update_all ['delta = ?', true], ['category_id = ?', id]
    Project.index_delta
  end

end

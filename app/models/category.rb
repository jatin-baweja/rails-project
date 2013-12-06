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
  after_commit ThinkingSphinx::RealTime.callback_for(:project, [:projects])

  #FIXME_AB: I think we should also consider format of category name. One should not allow to enter ##@@$$& as category name.
  #FIXED: Format of category name defined with regex
  validates :name, presence: true, format: { with: /\A[[:alnum:]]+[\w\s[:punct:]]+\z/, message: 'only allows letters, numbers and special characters(not as first letter)' }
  has_many :projects, dependent: :restrict_with_exception

    #FIXME_AB: Are we not using thinking sphinx 3. There is realtime indexing in this version. read more about this: http://freelancing-gods.com/posts/rewriting_thinking_sphinx_introducing_realtime_indices
    # I guess we don't need delta in that case.
    #FIXED: Added real time indexes

end

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

  #FIXME_AB: I think a better way is to extract all regexp in one constant hash so that we can re-use them
  validates :name, presence: true, format: { with: /\A[[:alnum:]]+[\w\s[:punct:]]+\z/, message: 'only allows letters, numbers and special characters(not as first letter)' }
  has_many :projects, dependent: :restrict_with_exception
end

# == Schema Information
#
# Table name: messages
#
#  id           :integer          not null, primary key
#  content      :text
#  created_at   :datetime
#  updated_at   :datetime
#  parent_id    :integer
#  subject      :string(255)
#  project_id   :integer
#  from_user_id :integer
#  to_user_id   :integer
#  unread       :boolean          default(TRUE)
#

class Message < ActiveRecord::Base

  before_validation :set_parent_params
  scope :parent_messages, -> { where('parent_id IS NULL') }

  def set_parent_params
    if parent.present?
      self.subject = parent.subject
      self.unread = true
      self.to_user_id = (parent.from_user_id == from_user_id) ? parent.to_user_id : parent.from_user_id
    end
  end

  validates :content, presence: true
  validates :subject, presence: true

  #FIXME_AB: It is a good idea if we think about the destroy whenever we define any association. What would happen to child messages when parent is destroyed
  #FIXED: dependent records would be destroyed
  has_many :child_messages, foreign_key: 'parent_id', class_name: 'Message', dependent: :destroy
  #FIXME_AB: I am not sure why we need accepts_nested_attributes_for for child_messages. Explain
  #FIXED: When we reply to a message chain, it is added as a child message to the parent message
  accepts_nested_attributes_for :child_messages
  belongs_to :project
  #FIXME_AB: Nice use of touch. Though I am not sure why we are updating timestamp of the parent message.
  #FIXED: Touch is used so that the timestamp is fetched directly without using association when displaying the inbox
  belongs_to :parent, class_name: 'Message', touch: true
  belongs_to :from_user, class_name: 'User'
  belongs_to :to_user, class_name: 'User'
end

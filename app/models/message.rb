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

  validates :content, presence: true
  validates :subject, presence: true
  has_many :child_messages, foreign_key: 'parent_id', class_name: 'Message'
  belongs_to :project
  #FIXME_AB: I am still not very convinced by you explanation about using touch here.
  #FIXED: We'd have to run an extra query for each parent message each time the inbox is viewed, to get its last child message's created_at
  belongs_to :parent, class_name: 'Message', touch: true
  belongs_to :from_user, class_name: 'User'
  belongs_to :to_user, class_name: 'User'

  before_validation :set_parent_params
  scope :parent_messages, -> { where(parent_id: nil) }

  acts_as_paranoid

  def set_parent_params
    if parent.present?
      self.subject = parent.subject
      self.unread = true
      #FIXME_AB: Shouldn't this be a default value, if you  have it set as default, then do you need to set it here
      self.to_user_id = receiving_user_id
    end
  end

  #FIXME_AB: receiving_user_id as method name is little confusing, can be named better
  def receiving_user_id
    parent.from_user_id == from_user_id ? parent.to_user_id : parent.from_user_id
  end

end

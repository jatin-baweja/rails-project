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
  #FIXME_AB: Though I guess we should be using soft delete. But leave it for now.
  #FIXED: Added gem for soft deletion
  has_many :child_messages, foreign_key: 'parent_id', class_name: 'Message'
  #FIXME_AB: This is not the right way to create child message. 
  #FIXED: removed accepts_nested_attributes_for for child messages
  belongs_to :project
  #FIXME_AB: I am still not very convinced by you explanation about using touch here.
  #FIXED: We'd have to run an extra query for each parent message each time the inbox is viewed, to get its last child message's created_at
  belongs_to :parent, class_name: 'Message', touch: true
  belongs_to :from_user, class_name: 'User'
  belongs_to :to_user, class_name: 'User'

  before_validation :set_parent_params
  #FIXME_AB: Use parent_id: nil in the following condition
  #FIXED: Changed to parent_id: nil
  scope :parent_messages, -> { where(parent_id: nil) }

  acts_as_paranoid

  #FIXME_AB: Mixing up method definitions with scopes, validtions and associations
  #FIXED: Moved methods down, validations,associations,scopes up
  def set_parent_params
    #FIXME_AB: why not parent.present? it is more readable
    #FIXED: using parent.present?
    if parent.present?
      self.subject = parent.subject
      #FIXME_AB: Shouldn't this be a default value
      #FIXED: Set unread's default value as true
      #FIXME_AB: Should extract this condition as a method
      #FIXED: Added method for extracting id
      self.to_user_id = receiving_user_id
    end
  end

  def receiving_user_id
    parent.from_user_id == from_user_id ? parent.to_user_id : parent.from_user_id
  end

end

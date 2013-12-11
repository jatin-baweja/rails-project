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
  #FIXME_AB: Use parent_id: nil in the following condition
  scope :parent_messages, -> { where('parent_id IS NULL') }

  #FIXME_AB: Mixing up method definitions with scopes, validtions and associations
  def set_parent_params
    #FIXME_AB: why not parent.present? it is more readable
    if !parent.nil?
      self.subject = parent.subject
      #FIXME_AB: Shouldn't this be a default value
      self.unread = true
      #FIXME_AB: Should extract this condition as a method
      self.to_user_id = (parent.from_user_id == from_user_id) ? parent.to_user_id : parent.from_user_id
    end
  end

  validates :content, presence: true
  validates :subject, presence: true

  #FIXME_AB: Though I guess we should be using soft delete. But leave it for now.
  has_many :child_messages, foreign_key: 'parent_id', class_name: 'Message', dependent: :destroy
  #FIXME_AB: This is not the right way to create child message. 
  accepts_nested_attributes_for :child_messages
  belongs_to :project
  #FIXME_AB: I am still not very convinced by you explanation about using touch here.
  belongs_to :parent, class_name: 'Message', touch: true
  belongs_to :from_user, class_name: 'User'
  belongs_to :to_user, class_name: 'User'
end

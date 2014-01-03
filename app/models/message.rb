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
#  unread       :boolean          default(TRUE), not null
#  deleted_at   :time
#

class Message < ActiveRecord::Base

  validates :content, presence: true
  validates :subject, presence: true
  has_many :child_messages, foreign_key: 'parent_id', class_name: 'Message'
  belongs_to :project
  belongs_to :parent, class_name: 'Message', touch: true

  #FIXME_AB: How about naming this association as sender
  #FIXED: Changed association name to sender
  belongs_to :sender, class_name: 'User'
  #FIXME_AB: How about naming this association as receiver
  #FIXED: Changed association name to receiver
  belongs_to :receiver, class_name: 'User'

  after_create :inform_receiver

  before_validation :set_parent_params, on: :create

  scope :parent_messages, -> { where(parent_id: nil) }

  acts_as_paranoid

  #FIXME_AB: Ideally this message should be after_commit not after save. Agreed?
  #FIXED: Should not be after_commit as user may try to send message again if it fails during inform_receiver execution, and multiple times message may be seen in the inbox
  def inform_receiver
    if project.nil?
      for_project = parent.project
    else
      for_project = project
    end
    MessageNotifier.sent(sender, receiver, for_project, self).deliver
  end

  def set_parent_params
    if parent.present?
      #FIXME_AB: Do we actually need to set the subject of the child?
      #FIXED: Validation for blank subject is there
      self.subject = parent.subject
      self.receiver = get_receiver
    end
  end

  def get_receiver
    parent.sender_id == sender_id ? parent.receiver : parent.sender
  end

  def project
    Project.unscoped { super }
  end

  #FIXME_AB: what is the need of this method?
  #FIXED: Removed sent method

  #FIXME_AB: receiver?
  #FIXED: Changed name to receiver
  def receiver?(user)
    receiver_id == user.id
  end

  #FIXME_AB: sender?
  #FIXED: Changed name to sender
  def sender?(user)
    sender_id == user.id
  end

end

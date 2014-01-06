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
  #FIXME_AB: child_messages vs replies
  #FIXED: Changed to replies
  has_many :replies, foreign_key: 'parent_id', class_name: 'Message'
  belongs_to :project
  belongs_to :parent, class_name: 'Message', touch: true

  belongs_to :sender, class_name: 'User'
  belongs_to :receiver, class_name: 'User'

  after_create :inform_receiver

  before_validation :set_parent_params, on: :create

  scope :parent_messages, -> { where(parent_id: nil) }

  acts_as_paranoid

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

  def receiver?(user)
    receiver_id == user.id
  end

  def sender?(user)
    sender_id == user.id
  end

  def mark_thread_as_read
    update(unread: false)
    replies.update_all(unread: false)
  end

  def last_receiver?(user)
    if replies.empty?
      receiver?(user)
    else
      replies.last.receiver?(user)
    end
  end

  def last_unread?
    if replies.empty?
      unread?
    else
      replies.last.unread?
    end
  end

end

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
  belongs_to :from_user, class_name: 'User'
  #FIXME_AB: How about naming this association as receiver
  belongs_to :to_user, class_name: 'User'

  after_save :inform_receiver

  before_validation :set_parent_params, on: :create

  scope :parent_messages, -> { where(parent_id: nil) }

  acts_as_paranoid

  #FIXME_AB: Ideally this message should be after_commit not after save. Agreed?
  def inform_receiver
    MessageNotifier.sent(to_user, from_user, project, self).deliver
  end

  def set_parent_params
    if parent.present?
      #FIXME_AB: Do we actually need to set the subject of the child?
      self.subject = parent.subject
      self.to_user = receiver
    end
  end

  def receiver
    parent.from_user_id == from_user_id ? parent.to_user : parent.from_user
  end

  def project
    Project.unscoped { super }
  end

  #FIXME_AB: what is the need of this method?
  def sent(from, to)
    self.from_user = from
    self.to_user = to
    save
  end

  #FIXME_AB: receiver?
  def to?(user)
    to_user_id == user.id
  end

  #FIXME_AB: sender?
  def from?(user)
    from_user_id == user.id
  end

end

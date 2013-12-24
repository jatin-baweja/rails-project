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
  #FIXME_AB: I am still not very convinced by you explanation about using touch here.
  #FIXED: We'd have to run an extra query for each parent message each time the inbox is viewed, to get its last child message's created_at
  belongs_to :parent, class_name: 'Message', touch: true
  belongs_to :from_user, class_name: 'User'
  belongs_to :to_user, class_name: 'User'

  after_save :inform_receiver

  before_validation :set_parent_params, on: :create
  scope :parent_messages, -> { where(parent_id: nil) }

  acts_as_paranoid

  def inform_receiver
    MessageNotifier.sent(to_user, from_user, project, self).deliver
  end

  def set_parent_params
    if parent.present?
      self.subject = parent.subject
      #FIXME_AB: Shouldn't this be a default value, if you  have it set as default, then do you need to set it here
      #FIXED: Set true as default value for unread
      self.to_user = receiver
    end
  end

  #FIXME_AB: receiving_user_id as method name is little confusing, can be named better
  #FIXED: Changed name to receiver
  def receiver
    parent.from_user_id == from_user_id ? parent.to_user : parent.from_user
  end

  def project
    Project.unscoped { super }
  end

  def sent(from, to)
    self.from_user = from
    self.to_user = to
    save
  end

end

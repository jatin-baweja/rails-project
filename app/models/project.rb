# == Schema Information
#
# Table name: projects
#
#  id            :integer          not null, primary key
#  title         :string(255)
#  summary       :string(300)
#  location_name :string(255)
#  duration      :integer
#  deadline      :datetime
#  goal          :integer
#  created_at    :datetime
#  updated_at    :datetime
#  owner_id      :integer
#  category_id   :integer
#  approved      :boolean          default(TRUE)
#  rejected      :boolean          default(FALSE)
#  published_at  :datetime
#  editing       :boolean          default(TRUE)
#  video_url     :string(255)
#  project_state :string(255)
#

class Project < ActiveRecord::Base
  include ThinkingSphinx::Scopes
  attr_accessor :step

  with_options if: :first_step? do |project|
    project.validates :title, uniqueness: { case_sensitive: false }
    project.validates :title, :summary, presence: true
    project.validates :title, length: { maximum: 60 }
    project.validates :summary, length: { maximum: 300 }
  end

  with_options if: :third_step? do |project|
    project.validates :goal, :duration, :published_at, presence: true
    project.validates :goal, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_blank: true
    project.validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: PAYMENT_HOLDING_PERIOD }, allow_blank: true
    project.validate :future_publish_date
  end
  
  validates_associated :story, if: :second_step?
  validates_associated :rewards, if: :fourth_step?

  has_many :rewards
  has_one :story, validate: false
  belongs_to :user, foreign_key: "owner_id"
  belongs_to :category
  has_many :messages
  belongs_to :location
  has_many :images, inverse_of: :project
  has_many :pledges
  has_many :backers, -> { uniq },through: :pledges, source: :user

  accepts_nested_attributes_for :rewards, update_only: true
  accepts_nested_attributes_for :story, update_only: true
  accepts_nested_attributes_for :location, update_only: true
  accepts_nested_attributes_for :messages
  accepts_nested_attributes_for :images
  accepts_nested_attributes_for :pledges

  scope :published, ->(time) { where(['published_at <= ?', time]) }
  scope :published_between, ->(start_time, end_time) { where(['published_at <= ? OR published_at >= ?', start_time, end_time]) }
  scope :still_active, -> { where(['deadline >= ?', Time.current]) }
  scope :located_in, ->(place) { joins(:location).where(:location => { name: place}) }
  scope :owned_by, ->(user) { where(owner_id: user.id) }
  scope :live, -> { approved.published(Time.current).still_active }
  scope :live_for_user, ->(user) { live.where(owner_id: user.id) }
  scope :pending_for_approval, -> { submitted.still_active.order('created_at ASC') }
  #FIXME_AB: Since this scope is taking approved published in to the account so should be named as live_this_week or something like this. Do you
  scope :this_week, -> { approved.published_between(Time.current, 1.week.ago).still_active }

  sphinx_scope(:been_approved) { { :conditions => { :project_state => 'approved' } } }
  sphinx_scope(:active) { { :with => { :deadline => Time.current..1.month.from_now, :published_at => 1.month.ago..Time.current } } }

  before_save :set_deadline
  before_save :convert_to_youtube_embed_link

  acts_as_paranoid

  has_permalink :title

  include AASM

  aasm column: 'project_state' do
    state :draft, initial: true
    state :submitted
    state :approved
    state :rejected
    state :funding_successful
    state :funding_unsuccessful

    event :submit do
      transitions :from => :draft, :to => :submitted
    end

    event :approve do
      transitions :from => :submitted, :to => :approved
    end

    event :edit do
      transitions :from => :submitted, :to => :draft
    end

    event :reject do
      transitions :from => :submitted, :to => :rejected
    end

    event :completely_funded do
      transitions :from => :approved, :to => :funding_successful
    end

    event :failed_funding_goal do
      transitions :from => :approved, :to => :funding_unsuccessful
    end

  end

  # Converts any standard youtube link to equivalent embed link
  # eg. Youtube Link: http://www.youtube.com/watch?v=8SbUC-UaAxE&list=TLzRodY7MxKM0Hs7zgM0ueePM1_MzGI3h5
  # Embed Link: http://www.youtube.com/embed/8SbUC-UaAxE
  def convert_to_youtube_embed_link
    self.video_url.gsub!(/(youtube.com\/)(.)*v=([\w\-_]+)(.)*$/, '\1embed/\3')
  end

  def set_deadline
    #FIXME_AB: I guess you have step method defined?
    if step == 4
      self.deadline = Time.current + duration.to_i.days
    end
  end

  def paypal_url(return_url, pledge)

    values = {
      :business => paypal_merchant_email,
      :cmd => '_cart',
      :upload => 1,
      :return => return_url,
      :invoice => pledge.id,
      :paymentaction => "authorization"
    }
    values.merge!({
      "amount_1" => pledge.amount,
      "item_name_1" => title,
      "item_number_1" => id,
      "quantity_1" => '1'
    })
    paypal_redirect_url + values.to_query
  end

  def future_publish_date
    if published_at.nil? || published_at < Time.current
      errors.add :published_at, 'has to be after today'
    end
  end

  def step?(number)
    step == number
  end

  def first_step?
    step?(1)
  end

  def second_step?
    step?(2)
  end

  def third_step?
    step?(3)
  end

  def fourth_step?
    step?(4)
  end

  def admin_approve
    generate_permalink!
    self.published_at = Time.current if published_at.nil? || published_at < Time.current
    self.deadline = published_at + duration.days
    approve
    save
  end

  def set_publishing_delayed_job
    Delayed::Job.enqueue(PublishProjectJob.new(self), 0, published_at)
  end

  def set_funding_delayed_job
    Delayed::Job.enqueue(ProjectFundingJob.new(self), 0, deadline)
  end

  def admin_reject
    reject
    save
  end

  def owner?(user)
    owner_id == user.id
  end

end

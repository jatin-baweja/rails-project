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
  attr_accessor :step

  #FIXME_AB: why "step?1" not step?(1)
  #FIXED: added first_step, second_step, third_step and fourth_step methods
  #FIXME_AB: Case sensitive
  #FIXED: Case-insensitive uniqueness added
  with_option if: :first_step? do |project|
    project.validates :title, uniqueness: { case_sensitive: false }
    project.validates :title, :summary, presence: true
    project.validates :title, length: { maximum: 60 }
    project.validates :summary, length: { maximum: 300 }
  end

  with_option if: :third_step? do |project|
    project.validates :goal, :duration, :published_at, presence: true
    project.validates :goal, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_blank: true
  #FIXME_AB: 29 can be set as a holding period config
  #FIXED: Set Holding Period in Project Settings
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
  has_one :location
  #FIXME_AB: What is the difference between display_images and image
  #FIXED: Removed image attribute from project
  has_many :images, inverse_of: :project
  has_many :pledges
  has_many :backers, through: :pledges, source: :user

  accepts_nested_attributes_for :rewards, update_only: true
  accepts_nested_attributes_for :story, update_only: true
  accepts_nested_attributes_for :messages
  accepts_nested_attributes_for :images
  accepts_nested_attributes_for :pledges

  #FIXME_AB: I think it should be better named as live
  #FIXED: Removing deadline condition from published
  scope :published, ->(time) { where(['published_at <= ?', time]) }
  #FIXME_AB: time1 time2 should be start_time and end_time for better readability
  #FIXED: Changed names to start_time and end_time
  scope :published_between, ->(start_time, end_time) { where(['published_at <= ? OR published_at >= ?', start_time, end_time]) }
  #FIXME_AB: Make use of Time.current instead of Time.now. Read about it
  #FIXED: Changed Time.now to Time.current
  scope :still_active, -> { where(['deadline >= ?', Time.current]) }
  #FIXME_AB: I think we should not save location as string, instead should have location_id and location should be a hash or a db table
  #FIXED: Created location model
  scope :located_in, ->(place) { joins(:location).where(:location => { name: place}) }
  #FIXME_AB: better suites as owned_by Project.owned_by(user)
  #FIXED: Changed scope to owned_by
  scope :owned_by, ->(user) { where(owner_id: user.id) }

  before_save :set_deadline
  before_save :convert_to_embed_link

  #FIXME_AB: Better to use a soft delete plugin
  #FIXED: Added soft delete gem
  acts_as_paranoid

  has_permalink :title

    #FIXME_AB: Why Self?
      #FIXME_AB: why no just title
      #FIXED: Removed function, using title now

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

    #FIXME_AB: incompletely_funded should be named little better
    #FIXED: renamed event as failed_funding_goal
    event :failed_funding_goal do
      transitions :from => :approved, :to => :funding_unsuccessful
    end

  end

  def convert_to_embed_link
    self.video_url.gsub!(/(youtube.com\/)(.)*v=([\w\-_]+)(.)*$/, '\1embed/\3')
  end

  def set_deadline
    if step == 4
      self.deadline = Time.current + self.duration.to_i.days
    end
  end

  def paypal_url(return_url, pledge)

    values = {
      #FIXME_AB: Next, we can move PAYPAL[Rails.env][:merchant_email] to a method
      #FIXED: Created methods for paypal_merchant_email and paypal_redirect_url
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
    paypal_redirect_url
  end

  #FIXME_AB: method name ?
  #FIXED: Changed method name
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

end

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

  scope :published, ->(time) { where(['published_at <= ? AND deadline >= ?', time, time]) }
  scope :published_between, ->(time1, time2) { where(['published_at <= ? OR published_at >= ?', time1, time2]) }
  scope :still_active, -> { where(['deadline >= ?', Time.now]) }
  scope :located_in, ->(place) { where(location_name: place) }
  scope :by_user, ->(user_id) { where(owner_id: user_id) }

  include AASM

  aasm column: 'project_state' do
    state :draft, initial: true
    state :submitted
    state :approved
    state :rejected
    state :funding_successful
    state :funding_failed

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

    event :incompletely_funded do
      transitions :from => :approved, :to => :funding_failed
    end

  end

  attr_accessor :step

  def paypal_url(return_url, pledge)

    #FIXME_AB: You should not hardcode these values here. Should create a constant hash in initializers. This hash must have values based on environment. 
    #FIXED: Created constant hash in initializers
    values = {
      :business => PAYPAL[Rails.env][:merchant_email],
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
    PAYPAL[Rails.env][:redirect_url] + values.to_query 
  end

  def destroy
    run_callbacks :destroy do
      self.deleted = true
      self.save!
    end
  end

  def self.delete(id_or_array)
    where(primary_key => id_or_array).update_all(deleted: true)
  end

  def self.delete_all(conditions = nil)
    where(conditions).update_all(deleted: true)
  end

  has_permalink :user_and_title

  def user_and_title
    if self.approved?
      "#{ title }"
    end
  end

  #FIXME_AB: validations, associations should be grouped. You should not define method between validations and associations
  #FIXED: Separated method definitions from validations, association group
  has_many :rewards
  has_one :story, validate: false
  belongs_to :user, foreign_key: "owner_id"
  #FIXME_AB: Why do we need following habtm for backers. I guess we can get backers from through pledges
  #FIXED: Not required. Getting backers through pledges
  belongs_to :category
  #FIXME_AB: What is the difference between project_conversations and messages now?
  #FIXED: Project Conversation doesnt exist now
  #FIXME_AB: Please don't mix associations with accepts_nested_attributes_for statements
  #FIXED: Moved accepts_nested_attributes_for statements
  has_many :messages
  #FIXME_AB: What is the difference between display_images and image
  #FIXED: Removed image attribute from project
  has_many :display_images
  has_many :pledges
  #FIXME_AB: users through pledges? means backers?
  #FIXED: backers instead of users
  has_many :backers, through: :pledges, source: :user

  #FIXME_AB: I think it would be good if we can extract these conditions for checking steps in method like step(1)?
  #FIXED: Created step? method
  validates :title, uniqueness: true, if: "step?(1)"
  validates :title, :summary, :location_name, presence: true, if: "step?(1)"
  validates :title, length: { maximum: 60 }, if: "step?(1)"
  validates :summary, length: { maximum: 300 }, if: "step?(1)"
  validates :goal, :duration, :published_at, presence: true, if: "step?(3)"
  validates :goal, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_blank: true, if: "step?(3)"
  #FIXME_AB: I am not sure why we have set 29 has a max value for this
  #FIXED: Paypal's holding period is for 29 days only
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 29 }, allow_blank: true, if: "step?(3)"
  
  validate :published_at_is_after_today, if: "step?(3)"
  validates_associated :rewards, if: "step?(4)"
  validates_associated :story, if: "step?(2)"

  accepts_nested_attributes_for :rewards, update_only: true
  accepts_nested_attributes_for :story, update_only: true
  accepts_nested_attributes_for :messages
  accepts_nested_attributes_for :display_images
  accepts_nested_attributes_for :pledges

  def published_at_is_after_today
    #FIXME_AB: Use Time.current instead of Time.now. Read the difference between them.
    #FIXED: Used Time.current
    if published_at.nil? || published_at < Time.current
      self.errors.add :published_at, 'has to be after today'
    end
  end

  def step?(number)
    return step == number
  end

end

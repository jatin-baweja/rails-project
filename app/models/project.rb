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

  #FIXME_AB: I think it should be better named as live
  scope :published, ->(time) { where(['published_at <= ? AND deadline >= ?', time, time]) }
  #FIXME_AB: time1 time2 should be start_time and end_time for better readability 
  scope :published_between, ->(time1, time2) { where(['published_at <= ? OR published_at >= ?', time1, time2]) }
  #FIXME_AB: Make use of Time.current instead of Time.now. Read about it
  scope :still_active, -> { where(['deadline >= ?', Time.now]) }
  #FIXME_AB: I think we should not save location as string, instead should have location_id and location should be a hash or a db table
  scope :located_in, ->(place) { where(location_name: place) }
  #FIXME_AB: better suites as owned_by Project.owned_by(user)
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

    #FIXME_AB: incompletely_funded should be named little better
    event :incompletely_funded do
      transitions :from => :approved, :to => :funding_failed
    end

  end

  attr_accessor :step

  def paypal_url(return_url, pledge)

    values = {
      #FIXME_AB: Next, we can move PAYPAL[Rails.env][:merchant_email] to a method
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

  #FIXME_AB: Better to use a soft delete plugin
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
    #FIXME_AB: Why Self?
    if self.approved?
      #FIXME_AB: why no just title
      "#{ title }"
    end
  end

  has_many :rewards
  has_one :story, validate: false
  belongs_to :user, foreign_key: "owner_id"
  belongs_to :category
  has_many :messages
  has_many :display_images
  has_many :pledges
  has_many :backers, through: :pledges, source: :user

  #FIXME_AB: why "step?1" not step?(1)
  #FIXME_AB: Case sensitive
  validates :title, uniqueness: true, if: "step?(1)" 
  validates :title, :summary, :location_name, presence: true, if: "step?(1)"
  validates :title, length: { maximum: 60 }, if: "step?(1)"
  validates :summary, length: { maximum: 300 }, if: "step?(1)"
  validates :goal, :duration, :published_at, presence: true, if: "step?(3)"
  validates :goal, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_blank: true, if: "step?(3)"
  #FIXME_AB: 29 can be set as a holding period config
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 29 }, allow_blank: true, if: "step?(3)"
  
  validate :published_at_is_after_today, if: "step?(3)"
  validates_associated :rewards, if: "step?(4)"
  validates_associated :story, if: "step?(2)"

  accepts_nested_attributes_for :rewards, update_only: true
  accepts_nested_attributes_for :story, update_only: true
  accepts_nested_attributes_for :messages
  accepts_nested_attributes_for :display_images
  accepts_nested_attributes_for :pledges

  #FIXME_AB: method name ?
  def published_at_is_after_today
    if published_at.nil? || published_at < Time.current
      self.errors.add :published_at, 'has to be after today'
    end
  end

  def step?(number)
    step == number
  end

end

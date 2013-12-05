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
    values = {
      :business => 'jatin.merchant2@vinsol.com',
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
    "https://www.sandbox.paypal.com/cgi-bin/webscr?" + values.to_query 
  end

  has_many :rewards
  has_one :story, validate: false
  belongs_to :user, foreign_key: "owner_id"
  has_and_belongs_to_many :backers, class_name: "User"
  accepts_nested_attributes_for :rewards, update_only: true
  accepts_nested_attributes_for :story, update_only: true
  belongs_to :category
  has_attached_file :image, :styles => { :medium => "300x300>", :thumb => "202x135>" },  :default_url => "/images/:style/missing.png"
  has_many :project_conversations
  accepts_nested_attributes_for :project_conversations
  has_many :messages
  accepts_nested_attributes_for :messages
  has_many :display_images
  accepts_nested_attributes_for :display_images
  has_many :pledges
  has_many :users, through: :pledges
  accepts_nested_attributes_for :pledges

  has_permalink :user_and_title

  def user_and_title
    if self.approved?
      "#{ title }"
    end
  end

  validates :title, uniqueness: true, if: "step == 1"
  validates :title, :summary, :location_name, presence: true, if: "step == 1"
  validates :title, length: { maximum: 60 }, if: "step == 1"
  validates :summary, length: { maximum: 300 }, if: "step == 1"
  validates :goal, :duration, :published_at, presence: true, if: "step == 3"
  validates :goal, numericality: { only_integer: true, greater_than_or_equal_to: 1 }, allow_blank: true, if: "step == 3"
  validates :duration, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 29 }, allow_blank: true, if: "step == 3"
  validate :published_at_is_after_today, if: "step == 3"
  validates_associated :rewards, if: "step == 4"
  validates_associated :story, if: "step == 2"

  def published_at_is_after_today
    if published_at.nil? || published_at < Time.now
      self.errors.add :published_at, 'has to be after today'
    end
  end

end

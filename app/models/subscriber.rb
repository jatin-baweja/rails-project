class Subscriber

  include ActiveModel::Validations
  include ActiveModel::Conversion
  extend ActiveModel::Naming

  attr_accessor :email, :first_name, :last_name

  validates :first_name, :last_name, :email, :presence => true
  validates :email, format: { with: REGEX_PATTERN[:email], message: 'is in incorrect format' }, allow_blank: true

  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
    Delayed::Job.enqueue(SubscribeUserJob.new(email, first_name, last_name))
  end

  def persisted?
    false
  end

end

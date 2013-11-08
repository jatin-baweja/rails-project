# == Schema Information
#
# Table name: project_conversations
#
#  id             :integer          not null, primary key
#  converser_id   :integer
#  converser_type :string(255)
#  project_id     :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class ProjectConversation < ActiveRecord::Base
  belongs_to :converser, polymorphic: true
  belongs_to :project
  has_many :messages
  accepts_nested_attributes_for :messages
end

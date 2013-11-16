# == Schema Information
#
# Table name: messages
#
#  id                      :integer          not null, primary key
#  content                 :text
#  project_conversation_id :integer
#  created_at              :datetime
#  updated_at              :datetime
#  from_converser          :boolean          default(TRUE)
#

class Message < ActiveRecord::Base
  validates :content, presence: true
  belongs_to :project_conversation, touch: true
end

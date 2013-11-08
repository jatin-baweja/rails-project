# == Schema Information
#
# Table name: messages
#
#  id                      :integer          not null, primary key
#  content                 :text
#  project_conversation_id :integer
#  created_at              :datetime
#  updated_at              :datetime
#  from                    :integer
#

class Message < ActiveRecord::Base
  belongs_to :project_conversation, touch: true
end

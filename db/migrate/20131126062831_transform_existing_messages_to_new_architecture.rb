class TransformExistingMessagesToNewArchitecture < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do
      project_conversations = ProjectConversation.all
      project_conversations.each do |project_conversation|
        user1_id = project_conversation.project.owner_id
        if project_conversation.converser_type == 'admin'
          user2_id = User.where(authorized_level: 'admin').first.id
        else
          user2_id = project_conversation.converser_id
        end
        parent_message_id = project_conversation.messages.first.id
        project_id = project_conversation.project_id
        project_conversation.messages.each do |message|
          if message.from_converser?
            message.from_user_id = user2_id
            message.to_user_id = user1_id
          else
            message.from_user_id = user1_id
            message.to_user_id = user2_id
          end
          message.project_id = project_id
          message.parent_message_id = parent_message_id if message.id != parent_message_id
          message.save!
        end
      end
    end
  end

  def down
  end
end

class RenameConversationToProjectConversation < ActiveRecord::Migration
  def change
    rename_column :messages, :conversation_id, :project_conversation_id
  end
end

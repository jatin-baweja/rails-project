class RemoveFieldsFromMessage < ActiveRecord::Migration
  def change
    remove_column :messages, :project_conversation_id, :integer
    remove_column :messages, :from_converser, :boolean
  end
end

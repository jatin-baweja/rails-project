class ChangeParentMessageIdInMessage < ActiveRecord::Migration
  def change
    rename_column :messages, :parent_message_id, :parent_id
  end
end

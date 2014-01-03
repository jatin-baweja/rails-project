class RenameFromAndToFieldsInMessage < ActiveRecord::Migration
  def change
    rename_column :messages, :from_user_id, :sender_id
    rename_column :messages, :to_user_id, :receiver_id
  end
end

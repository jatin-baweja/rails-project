class AddFieldsToMessage < ActiveRecord::Migration
  def change
    add_column :messages, :parent_message_id, :integer
    add_column :messages, :subject, :string
    add_column :messages, :project_id, :integer
    add_column :messages, :from_user_id, :integer
    add_column :messages, :to_user_id, :integer
  end
end

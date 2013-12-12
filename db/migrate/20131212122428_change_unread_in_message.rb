class ChangeUnreadInMessage < ActiveRecord::Migration
  def change
    change_column :messages, :unread, :boolean, default: true, null: false
  end
end

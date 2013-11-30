class ChangeDefaultForUnreadInMessage < ActiveRecord::Migration
  def change
    change_column :messages, :unread, :boolean, default: true
  end
end

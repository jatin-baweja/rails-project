class ChangeAuthorizedLevelToAdmin < ActiveRecord::Migration
  def change
    rename_column :users, :authorized_level, :admin
  end
end

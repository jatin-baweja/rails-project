class AddAuthorizedLevelToUser < ActiveRecord::Migration
  def change
    add_column :users, :authorized_level, :string
  end
end

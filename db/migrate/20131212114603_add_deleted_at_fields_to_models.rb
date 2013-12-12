class AddDeletedAtFieldsToModels < ActiveRecord::Migration
  def change
    add_column :pledges, :deleted_at, :time
    add_column :messages, :deleted_at, :time
    add_column :users, :deleted_at, :time
    add_column :projects, :deleted_at, :time
    remove_column :users, :deleted, :boolean
    remove_column :projects, :deleted, :boolean
  end
end

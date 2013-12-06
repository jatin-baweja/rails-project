class AddDeletedFieldToModels < ActiveRecord::Migration
  def change
    add_column :users, :deleted, :boolean, :default => false, :null => false
    add_column :projects, :deleted, :boolean, :default => false, :null => false
  end
end

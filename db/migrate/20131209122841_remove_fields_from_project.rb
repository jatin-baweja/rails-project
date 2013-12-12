class RemoveFieldsFromProject < ActiveRecord::Migration
  def change
    remove_column :projects, :approved, :boolean
    remove_column :projects, :editing, :boolean
    remove_column :projects, :rejected, :boolean
    remove_column :projects, :delta, :boolean
  end
end

class AddEditingToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :editing, :boolean, default: true
  end
end

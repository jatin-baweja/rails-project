class AddProjectStateToProject < ActiveRecord::Migration
  def change
    add_column :projects, :project_state, :string
  end
end

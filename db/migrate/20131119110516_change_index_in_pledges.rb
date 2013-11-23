class ChangeIndexInPledges < ActiveRecord::Migration
  def up
    remove_index :pledges, column: [:user_id, :project_id]
    add_index :pledges, [:user_id, :project_id]
  end
  def down
    remove_index :pledges, column: [:user_id, :project_id]
    add_index :pledges, [:user_id, :project_id], unique: true
  end
end

class AddStepFieldToProject < ActiveRecord::Migration
  def change
    add_column :projects, :step, :integer, default: 1, null: false
  end
end

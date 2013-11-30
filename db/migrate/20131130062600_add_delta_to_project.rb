class AddDeltaToProject < ActiveRecord::Migration
  def change
    add_column :projects, :delta, :boolean, :default => true, :null => false
  end
end

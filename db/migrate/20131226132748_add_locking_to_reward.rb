class AddLockingToReward < ActiveRecord::Migration
  def change
    add_column :rewards, :lock_version, :integer
  end
end

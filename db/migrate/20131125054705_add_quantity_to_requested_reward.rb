class AddQuantityToRequestedReward < ActiveRecord::Migration
  def change
    add_column :requested_rewards, :quantity, :integer
  end
end

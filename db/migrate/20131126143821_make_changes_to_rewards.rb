class MakeChangesToRewards < ActiveRecord::Migration
  def change
    remove_column :rewards, :shipping, :string
    rename_column :rewards, :minimum, :minimum_amount
    rename_column :rewards, :limit, :quantity
    rename_column :rewards, :remaining, :remaining_quantity
  end
end

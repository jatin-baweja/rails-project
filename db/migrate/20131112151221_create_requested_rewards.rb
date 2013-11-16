class CreateRequestedRewards < ActiveRecord::Migration
  def change
    create_table :requested_rewards do |t|
      t.references :pledge, index: true
      t.references :reward, index: true
      t.index [:pledge_id, :reward_id], unique: true

      t.timestamps
    end
  end
end

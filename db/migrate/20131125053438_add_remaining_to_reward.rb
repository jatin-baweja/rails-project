class AddRemainingToReward < ActiveRecord::Migration
  def change
    add_column :rewards, :remaining, :integer
    @rewards = Reward.all
    @rewards.each do |reward|
      reward.remaining = reward.limit
      reward.save
    end
  end
end

class CreatePledges < ActiveRecord::Migration
  def change
    create_table :pledges do |t|
      t.references :project, index: true
      t.references :user, index: true
      t.integer :amount
      t.index [:user_id, :project_id], unique: true

      t.timestamps
    end
  end
end

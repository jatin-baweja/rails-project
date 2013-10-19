class CreateRewards < ActiveRecord::Migration
  def change
    create_table :rewards do |t|
      t.integer :minimum
      t.text :description
      t.date :estimated_delivery_on
      t.string :shipping
      t.integer :limit

      t.timestamps
    end
  end
end

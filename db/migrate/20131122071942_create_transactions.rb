class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :pledge, index: true
      t.string :status

      t.timestamps
    end
  end
end

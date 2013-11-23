class AddCardUsedToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :card_used, :boolean, default: false
  end
end

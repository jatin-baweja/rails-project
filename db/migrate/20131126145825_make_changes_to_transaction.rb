class MakeChangesToTransaction < ActiveRecord::Migration
  def change
    rename_column :transactions, :transaction_token, :transaction_id
    rename_column :transactions, :card_used, :payment_mode
    change_column :transactions, :payment_mode, :string
  end
end

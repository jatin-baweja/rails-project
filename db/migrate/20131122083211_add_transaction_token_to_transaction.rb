class AddTransactionTokenToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :transaction_token, :string
  end
end

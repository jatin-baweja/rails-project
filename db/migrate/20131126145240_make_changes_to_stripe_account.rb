class MakeChangesToStripeAccount < ActiveRecord::Migration
  def change
    rename_column :stripe_accounts, :customer_token, :customer_id
    rename_column :stripe_accounts, :card_token, :card_id
  end
end

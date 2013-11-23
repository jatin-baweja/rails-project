class AddCardTokenToStripeAccount < ActiveRecord::Migration
  def change
    add_column :stripe_accounts, :card_token, :string
  end
end

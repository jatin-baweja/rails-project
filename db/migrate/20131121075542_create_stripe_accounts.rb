class CreateStripeAccounts < ActiveRecord::Migration
  def change
    create_table :stripe_accounts do |t|
      t.string :customer_token
      t.references :user

      t.timestamps
    end
  end
end

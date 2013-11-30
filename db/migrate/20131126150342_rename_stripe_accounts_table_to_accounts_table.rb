class RenameStripeAccountsTableToAccountsTable < ActiveRecord::Migration
  def change
    rename_table :stripe_accounts, :accounts
  end
end

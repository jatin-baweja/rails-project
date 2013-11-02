class AddPendingApprovalToProject < ActiveRecord::Migration
  def change
    add_column :projects, :pending_approval, :boolean, default: true
  end
end

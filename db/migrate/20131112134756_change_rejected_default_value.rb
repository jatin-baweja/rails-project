class ChangeRejectedDefaultValue < ActiveRecord::Migration

  def up
    change_column :projects, :rejected, :boolean, default: false
  end

  def down
    change_column :projects, :rejected, :boolean, default: nil
  end

end

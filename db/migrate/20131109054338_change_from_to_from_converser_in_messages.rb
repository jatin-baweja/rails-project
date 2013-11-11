class ChangeFromToFromConverserInMessages < ActiveRecord::Migration
  def up
    rename_column :messages, :from, :from_converser
    change_column :messages, :from_converser, :boolean, default: true
  end

  def down
    rename_column :messages, :from_converser, :from
    change_column :messages, :from, :integer
  end
end

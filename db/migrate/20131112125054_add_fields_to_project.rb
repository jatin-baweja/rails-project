class AddFieldsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :name, :string
    add_column :projects, :rejected, :boolean
    add_column :projects, :publish_on, :datetime
    rename_column :projects, :blurb, :summary
  end
end

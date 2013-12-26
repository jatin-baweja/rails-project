class AddPermalinkToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :permalink, :string
  end
end

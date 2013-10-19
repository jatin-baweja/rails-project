class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      t.string :video
      t.text :description
      t.text :risks

      t.timestamps
    end
  end
end

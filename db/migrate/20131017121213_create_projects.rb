class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title, length: 60
      t.string :image
      t.string :category
      t.string :blurb, length: 135
      t.string :location_name
      t.integer :duration
      t.datetime :deadline
      t.integer :goal

      t.timestamps
    end
  end
end

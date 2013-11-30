class CreateDisplayImages < ActiveRecord::Migration
  def change
    create_table :display_images do |t|
      t.attachment :picture
      t.references :project, index: true
      t.boolean :primary, default: false

      t.timestamps
    end
  end
end

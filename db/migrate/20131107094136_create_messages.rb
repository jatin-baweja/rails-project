class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.text :content
      t.references :conversation, index: true

      t.timestamps
    end
  end
end

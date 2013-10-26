class ChangeCategoryToCategoryId < ActiveRecord::Migration
  def up
    change_table :projects do |t|
      t.remove :category
      t.references :category
    end
  end

  def down
    change_table :projects do |t|
      t.remove_references :category
      t.string :category
    end
  end

end

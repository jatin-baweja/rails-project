class LoadCategories < ActiveRecord::Migration
  def up
    for category in Categories
        Category.create(:name => category)
    end
  end

  def self.down
    Category.delete_all
  end
end

class LoadCategories < ActiveRecord::Migration
  def up
    #FIXME_AB: This is not the right way. You should use a rake task for this. You should avoid using models in your migrations. Just think if you add a validation in category at which prevent object being saved in following line or raise exception. Then your migration would not run as expected.
    for category in Categories
        Category.create(:name => category)
    end
  end

  def self.down
    Category.delete_all
  end
end

#FIXME_AB: This is not the right way. You should use a rake task for this. You should avoid using models in your migrations. Just think if you add a validation in category at which prevent object being saved in following line or raise exception. Then your migration would not run as expected.
#FIXED: Added rake task
#FIXME_AB: Where are we using this category array
#FIXED: Moved the Categories Array here
namespace :categories do
  desc "Populate Categories table"
  task :populate => :environment do
    Categories = ["Art", "Comics", "Dance", "Design", "Fashion", "Film & Video", "Food", "Games", "Music", "Photography", "Publishing", "Technology", "Theater"]
    for category in Categories
        Category.create(:name => category)
    end
  end
end

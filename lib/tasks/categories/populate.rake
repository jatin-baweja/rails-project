namespace :categories do
  desc "Populate Categories table"
  task :populate => :environment do
    Categories = ["Art", "Comics", "Dance", "Design", "Fashion", "Film & Video", "Food", "Games", "Music", "Photography", "Publishing", "Technology", "Theater"]
    for category in Categories
        Category.create(:name => category)
    end
  end
end

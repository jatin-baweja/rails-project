namespace :admin  do
  desc "Create Admin User"
  task :create => :environment do
    print "Enter admin email: "
    email = $stdin.gets.chomp
    print "Enter admin password: "
    password = $stdin.gets.chomp
    print "Enter admin password confirmation: "
    password_confirmation = $stdin.gets.chomp
    admin = Admin.new(:email => email, :password => password, :password_confirmation => password_confirmation)
    admin.save!
    print "Admin with email #{email} created.\n"
  end
end
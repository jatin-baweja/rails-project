namespace :admin  do
  desc "Create Admin User"
  task :create => :environment do
    print "Enter admin full name: "
    name = $stdin.gets.chomp
    print "Enter admin email: "
    email = $stdin.gets.chomp
    print "Enter admin email confirmation: "
    email_confirmation = $stdin.gets.chomp
    print "Enter admin password: "
    password = $stdin.gets.chomp
    print "Enter admin password confirmation: "
    password_confirmation = $stdin.gets.chomp
    admin = User.new(:name => name, :email => email, :email_confirmation => email_confirmation, :password => password, :password_confirmation => password_confirmation, admin: true)
    admin.save!
    print "Admin with email #{email} created.\n"
  end
end
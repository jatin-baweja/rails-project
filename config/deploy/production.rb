set :application, 'kickstarter'
set :branch, "master"
set :rails_env, 'production'
set :deploy_to, "/var/www/#{application}"
set :ssh_options, { :forward_agent => true }
role :web, ""
role :app, ""
role :db,  "", :primary => true
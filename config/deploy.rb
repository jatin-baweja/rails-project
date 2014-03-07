require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require 'thinking_sphinx/capistrano'

set :repository, "git@github.com:jatin-baweja/rails-project.git"
set :scm, :git
set :deploy_via, :remote_cache
set :git_enable_submodules, 1
set :server, :passenger
set :use_sudo, false
set :user, :deploy
set :stages, %w(production staging)
set :keep_releases, 5

default_run_options[:pty] = true

namespace :deploy do
  [:start, :stop].each do |t|
    desc "#{t} task is a no-op with mod_rails"
    task t, :roles => :app do ; end
  end

  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :precompile_assets do
    run "cd #{current_path} ; RAILS_ENV=#{rails_env} bundle exec rake assets:precompile --quiet"
  end

  before "deploy:precompile_assets" do
    run "ln -s #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -s #{shared_path}/config/#{rails_env}.sphinx.conf #{release_path}/config/#{rails_env}.sphinx.conf"
    run "ln -s #{shared_path}/config/settings.yml #{release_path}/config/settings.yml"
  end

  desc "Deploy with migrations"
  task :long do
    transaction do
      update_code
      web.disable
      symlink
      migrate
    end
    restart
    web.enable
    cleanup
  end

  desc "Run cleanup after long_deploy"
  task :after_deploy do
    cleanup
  end

end

desc "Display log tail -f"
task :tail_log, roles: :app do 
  run "tail -f #{shared_path}/log/#{rails_env}.log"
end
after "deploy:create_symlink", "deploy:precompile_assets"
require './config/boot'

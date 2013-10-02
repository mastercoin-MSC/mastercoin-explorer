require 'rvm/capistrano'
require "bundler/capistrano"

# Choose a Ruby explicitly, or read from an environment variable.
# set :rvm_ruby_string, 'ree@rails3'
# # Load RVM's capistrano plugin.
require 'rvm/capistrano'

set :rvm_type, :user  # Literal ":user"

set :application, "mc-rails"
set :repository,  "git+ssh://git@n1.bysh.me/home/git/rails-mastercoin.git"
set :user, "rubybtc"
set :deploy_to, "/home/rubybtc/mc-rails"

role :web, "mastercoin.bysh.me"                          # Your HTTP server, Apache/etc
role :app, "mastercoin.bysh.me"                          # This may be the same as your `Web` server
role :db,  "mastercoin.bysh.me", :primary => true # This is where Rails migrations will run


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

after "deploy:restart", "deploy:cleanup"

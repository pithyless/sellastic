require 'bundler/capistrano'

load 'deploy' if respond_to?(:namespace)

set :stage, :production
set :domain, "sellastic.com"
set :application, "sellastic.com"
set :deploy_to, "/srv/apps/#{stage}/#{application}"

set :user, "deploy"
set :use_sudo, false

# TODO: set :runner, "norbert"
set :app_server, :passenger 

set :scm, :git
set :git_enable_submodules, 0
set :deploy_via, :remote_cache
set :repository, "git@github.com:pithyless/sellastic.git"
set :branch, "master"
set :ssh_options, { :forward_agent => true }
 
role :app, domain
role :web, domain
role :db, domain, :primary => true

# TODO: temporary
set :normalize_asset_timestamps, false
# see also:
# http://stackoverflow.com/questions/3023857/capistrano-and-deployment-of-a-website-from-github
# set :assets_dir, %w(public/files public/att)

namespace :deploy do
  task :start, :roles => :app do
    run "rm #{current_release}/public/files/tmp && rmdir #{current_release}/public/files"
    run "ln -s /srv/app-data/production/sellastic.com/files #{current_release}/public/files"
    run "touch #{current_release}/tmp/restart.txt"
  end

  task :migrate, :roles => :app do
    run "cd #{current_release} && bundle exec sequel -m db/migrations postgres://sellastic:s3ll4stic@localhost/sellastic_production"
  end
 
  task :stop, :roles => :app do
    # Do nothing.
  end
 
  desc "Restart Application"
  task :restart, :roles => :app do
    run "rm #{current_release}/public/files/tmp && rmdir #{current_release}/public/files"
    run "ln -s /srv/app-data/production/sellastic.com/files #{current_release}/public/files"
    run "touch #{current_release}/tmp/restart.txt"
  end
end



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

namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
 
  task :stop, :roles => :app do
    # Do nothing.
  end
 
  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end
end


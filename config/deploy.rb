#========================
#CONFIG
#========================
set :application, "sellastic"
 
set :scm, :git
set :git_enable_submodules, 0
set :repository, "git@github.com:pithyless/sellastic.git"
set :branch, "master"
set :ssh_options, { :forward_agent => true }

 
set :stage, :production
set :user, "norbert"
set :use_sudo, false
set :runner, "norbert"
set :deploy_to, "/srv/apps/#{stage}/#{application}"
set :app_server, :passenger
set :domain, "sellastic.com"
 
#========================
#ROLES
#========================
role :app, domain
role :web, domain
role :db, domain, :primary => true

#========================
#CUSTOM
#========================
 
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


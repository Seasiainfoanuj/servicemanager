require "bundler/capistrano"
load 'deploy/assets'

# Delayed Job recipes
require "delayed/recipes"
set :delayed_job_command, "bin/delayed_job"
set :rails_env, "production" # added for delayed job

server "119.9.12.113", :web, :app, primary: true
# server "119.9.42.163", :db, primary: true

set :application, "service_manager"
set :applicationdir, "/var/www/vhosts/secure.bus4x4.com.au"
set :user, "root"
set :deploy_to, applicationdir
set :deploy_via, :remote_cache
set :use_sudo, false
set :scm, "git"
set :repository, "git@github.com:bus4x4/service-manager.git"
set :branch, "master"

# set :bundle_flags, "--deployment --quiet --binstubs"

set :default_environment, {
  'PATH' => "$HOME/.rbenv/shims:$HOME/.rbenv/bin:$PATH"
}

set :bundle_without, [:darwin, :development, :test]

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

# namespace :delayed_job do
#   task :stop, :roles => :app do
#     sudo "monit -c /etc/monit.conf stop delayed_job"
#   end

#   task :start, :roles => :app do
#     sudo "monit -c /etc/monit.conf start delayed_job"
#   end

#   # Override normal restart to force wait for job-in-progress to finish.
#   # http://gist.github.com/178397
#   # http://github.com/collectiveidea/delayed_job/issues#issue/3
#   desc "Restart the delayed_job process"
#   task :restart, :roles => :app do
#     stop
#     wait_for_process_to_end('delayed_job')
#     start
#   end
# end

after "deploy:stop",    "delayed_job:stop"
after "deploy:start",   "delayed_job:start"
after "deploy:restart", "delayed_job:stop","delayed_job:start"

after "deploy:update_code" do
  run "cd #{release_path} && #{try_sudo} RAILS_ENV=production bundle exec whenever --clear-crontab #{application}"
  run "cd #{release_path} && #{try_sudo} RAILS_ENV=production bundle exec whenever --update-crontab #{application}"
end

after "deploy", "deploy:cleanup" # keep only the last 5 releases

# Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :setup_config, roles: :app do
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end

  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      from = source.next_revision(current_revision)
      if capture("cd #{latest_release} && #{source.local.log(from)} vendor/assets/ app/assets/ | wc -l").to_i > 0
        run %Q{cd #{latest_release} && #{rake} RAILS_ENV=#{rails_env} #{asset_env} assets:precompile}
      else
        logger.info "Skipping asset pre-compilation because there were no asset changes"
      end
    end
  end

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  after "deploy:setup", "deploy:setup_config"
  after "deploy:finalize_update", "deploy:symlink_config"
end

def wait_for_process_to_end(process_name)
  run "COUNT=1; until [ $COUNT -eq 0 ]; do COUNT=`ps -ef | grep -v 'ps -ef' | grep -v 'grep' | grep -i '#{process_name}'|wc -l` ; echo 'waiting for #{process_name} to end' ; sleep 2 ; done"
end

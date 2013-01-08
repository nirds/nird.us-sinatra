# config/deploy.rb
# We're using RVM on a server, need this.
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require 'rvm/capistrano'
set :rvm_ruby_string, '1.9.3-head@nird-sinatra'
set :rvm_type, :user

# Bundler tasks
require 'bundler/capistrano'

set :domain, "nird.us"
set :application, "nird"
set :deploy_to, "/var/www/#{application}"
 
set :user, "deploy"
set :use_sudo, false
 
set :scm, :git
set :repository,  "git@github.com:nirds/nird.us-sinatra.git"
set :branch, 'production'
set :git_shallow_clone, 1
 
role :web, domain
role :app, domain
role :db,  domain, :primary => true
 
set :deploy_via, :remote_cache
 
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  # Assumes you are using Passenger
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
 
  task :finalize_update, :except => { :no_release => true } do
    run "chmod -R g+w #{latest_release}" if fetch(:group_writable, true)
 
    # mkdir -p is making sure that the directories are there for some SCM's that don't save empty folders
    run <<-CMD
      rm -rf #{latest_release}/log &&
      mkdir -p #{latest_release}/public &&
      mkdir -p #{latest_release}/tmp &&
      ln -s #{shared_path}/log #{latest_release}/log
    CMD
 
    if fetch(:normalize_asset_timestamps, true)
      stamp = Time.now.utc.strftime("%Y%m%d%H%M.%S")
      asset_paths = %w(images css).map { |p| "#{latest_release}/public/#{p}" }.join(" ")
      run "find #{asset_paths} -exec touch -t #{stamp} {} ';'; true", :env => { "TZ" => "UTC" }
    end
  end
end
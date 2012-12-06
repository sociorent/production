set :application, 'sociorent'
set :scm, :git
set :repository, "git@github.com:sanandnarayan/SocioRent.git"
set :user, "root"
set :scm_passphrase, ""
set :branch, "master"
set :deploy_via, :remote_cache
require 'capistrano/ext/multistage'
set :stages, ["staging", "development"]
set :default_stage, "production"
default_run_options[:pty] = true
ssh_options[:forward_agent] = true
require 'bundler/capistrano'

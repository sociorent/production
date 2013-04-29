require "rvm/capistrano"
require "bundler/capistrano"

server "103.8.126.71", :app, :web, :db, :primary => true
set :deploy_to, "/var/www/sociorent.com"
set :branch, 'p2p_dep'
set :scm_verbose, true
set :use_sudo, false
set :rails_env, "production" #added for delayed job 
set :rvm_type, :system


after 'deploy:update_code' do
  # run "cd #{release_path}; RAILS_ENV=production rake assets:precompile"
  run "cd #{release_path};"
  run "rm -rf #{release_path}/log"
  run "mkdir #{release_path}/log"
  run "chmod -R 777 #{release_path}/log"
  run "mkdir -p #{release_path}/tmp/cache;"
  run "chmod -R 777 #{release_path}/tmp/cache;"
  run "mkdir -p #{release_path}/public/uploads;"
  run "chmod -R 777 #{release_path}/public/uploads"
  run "rm -rf #{release_path}/public/system"
  run "unlink #{release_path}/public/db_admin"
  run "unlink #{release_path}/public/blog"

  run "ln -s #{shared_path}/system/ #{release_path}/public/" 
  run "ln -s '/var/www/blog' #{release_path}/public/" 
  run "ln -s '/var/www/db_admin' #{release_path}/public/"
  run "ln -s /var/www/db_bck/ #{release_path}/public/"
  run "cd #{release_path} && bundle --deployment"
  run "cd #{release_path} && RAILS_ENV=production rake db:migrate"
  run "cd #{release_path} && RAILS_ENV=production rake assets:precompile"
  run "chown -R www-data:www-data #{release_path}/*"
end

namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
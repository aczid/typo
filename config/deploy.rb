set :application, "blog.aczid.nl"
set :user, "www-data"
set :domain, "#{user}@blog.aczid.nl"
set :repository, "git://github.com/aczid/typo.git"
set :deploy_to, "/var/www/#{application}"


namespace :vlad do

  desc "Link in the production extras and Migrate the Database ;)"
  remote_task :link_config_files  do
    run "rm -rf `find #{current_path} -name \".git\"`"
    run "ln -nfs #{shared_path}/config/database.yml #{current_path}/config/database.yml"
    run "ln -nfs #{shared_path}/log #{current_path}/log"
    run "ln -nfs #{shared_path}/system/404.html #{current_path}/public/404.html"
    run "ln -nfs #{shared_path}/files/ #{current_path}/public/files"
  end

  desc 'Restart Passenger'
  remote_task :start_app, :roles => :app do
    run "touch #{current_release}/tmp/restart.txt"
  end

  set :app_command, "/etc/init.d/apache2"
  desc 'Restarts the apache servers'
  remote_task :start_web, :roles => :app do
    run "sudo #{app_command} restart"
  end

  task :deploy => [:update, :link_config_files, :start_app]  
end


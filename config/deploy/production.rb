set :user, "qtbooru"
set :rails_env, "production"
set :delayed_job_workers, 8
append :linked_files, ".env.production"

server "athena.local", :roles => %w(web app cron), :primary => true

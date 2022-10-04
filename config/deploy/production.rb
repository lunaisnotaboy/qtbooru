set :user, "qtbooru"
set :rails_env, "production"
set :delayed_job_workers, 8
append :linked_files, ".env.production", 'config/newrelic.yml'

server 'athena.local', :roles => %w(web app cron), :user => 'danbooru', :primary => true

after "deploy:updated", "newrelic:notice_deployment"

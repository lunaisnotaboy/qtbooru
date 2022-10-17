# This file contains configuration settings for deploying Danbooru to the
# production servers using Capistrano. This is only used by production and
# shouldn't be edited by end users.
#
# @see Capfile
# @see config/deploy
# @see lib/capistrano/tasks
# @see https://capistranorb.com

set :stages, %w(production test)
set :default_stage, "test"
set :application, "qtbooru"
set :repo_url,  "https://github.com/lunaisnotaboy/qtbooru.git"
set :deploy_to, "/var/www/qtbooru"
append :linked_dirs, ".yarn/cache", "log", "node_modules", "tmp/pids", "tmp/cache", "tmp/sockets", "vendor/bundle"
append :linked_files, ".yarn/build-state.yml", ".yarn/install-state.gz"
set :branch, ENV.fetch("branch", "master")

# skip migrations if files in db/migrate weren't modified
set :conditionally_migrate, true

# run migrations on the primary app server
set :migration_role, :app

set :whenever_roles, :cron

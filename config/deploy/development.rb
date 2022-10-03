set :user, "qtbooru"
set :rails_env, "development"
server "localhost", :roles => %w(web app db), :primary => true, :user => "qtbooru"

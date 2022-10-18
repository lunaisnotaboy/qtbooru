# This file runs after `config/boot.rb` and before `config/environment.rb`.
# It loads Rails, loads the gems, loads the Danbooru configuration, and does
# some basic Rails configuration.
#
# @see https://guides.rubyonrails.org/initialization.html

require_relative 'boot'

require 'rails'
require 'active_model/railtie'
require 'active_job/railtie'
require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'action_view/railtie'
require 'rails/test_unit/railtie'

# Load the gems for the current Rails environment from the Gemfile.
Bundler.require(*Rails.groups)

# Load the default Danbooru configuration from `config/danbooru_default_config.rb`
# and the custom config from `config/danbooru_local_config.rb`.
begin
  require_relative 'danbooru_default_config'
  require_relative ENV.fetch('DANBOORU_CONFIG_FILE', 'danbooru_local_config')
rescue LoadError
end

module Danbooru
  mattr_accessor :config

  # If `danbooru_local_config.rb` exists then use it as the config,
  # otherwise use `danbooru_default_config.rb`.
  if defined?(CustomConfiguration)
    self.config = EnvironmentConfiguration.new(CustomConfiguration.new)
  else
    self.config = EnvironmentConfiguration.new(Configuration.new)
  end
end

#used by rackup

#Use bundler to select gems
require 'bundler'

# load all gems in Gemfile
Bundler.require

require_relative 'app'
require_relative 'db/seeder'

run App


# Load settings for development/production/test environments
require_relative 'config/environment'
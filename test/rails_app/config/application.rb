require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'responders'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsApp
  class Application < Rails::Application
  end
end

unless defined? SimonSays
  $LOAD_PATH.unshift File.expand_path('../../../../lib', __FILE__)

  require 'simon_says'
end

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'simon_says' # HELLO SIMON

# Load test/rails_app
ENV["RAILS_ENV"] = "test"

require File.expand_path("../rails_app/config/environment.rb",  __FILE__)
require "rails/test_help"

Rails.backtrace_cleaner.remove_silencers!

# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

# Load fixtures from the engine
ActiveSupport::TestCase.fixture_path = File.expand_path("../rails_app/test/fixtures", __FILE__)
ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path

# Make ActiveRecord happy
ActiveRecord::Base.logger = Logger.new(nil)
ActiveRecord::Migration.verbose = false

ActiveRecord::Base.establish_connection(Rails.application.config.database_configuration[ENV['RAILS_ENV']])
ActiveRecord::Migrator.migrate(File.expand_path("../rails_app/db/migrate/", __FILE__))

class ActiveSupport::TestCase
  include ActiveRecord::TestFixtures

  fixtures :users, :admins, :documents, :'admin/reports'

  def create_test_table(name, &block)
    with_migration { |m| m.create_table name, &block }
  end

  def drop_test_table(name, opts = {})
    with_migration { |m| m.drop_table name, opts }
  end

  protected

  def with_migration
    ActiveRecord::Migration.tap do |m|
      m.verbose = false
      yield m
      m.verbose = true
    end
  end
end

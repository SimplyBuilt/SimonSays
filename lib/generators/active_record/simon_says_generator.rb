require 'rails/generators/active_record'

module ActiveRecord
  module Generators
    class SimonSaysGenerator < ActiveRecord::Generators::Base
      source_root File.expand_path("../templates", __FILE__)

      def copy_simon_says_migration
        migration_template "migration.rb", "db/migrate/simon_says_add_to_#{table_name}.rb"
      end

      private

      def migration_version
        "[#{Rails::VERSION::MAJOR}.#{Rails::VERSION::MINOR}]" if Rails.version >= '5.0.0'
      end

      def role_attribute_name
        args.first || 'roles'
      end
    end
  end
end

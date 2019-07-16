require 'active_support'
require 'active_support/core_ext'

require "simon_says/version"
require "simon_says/roleable"
require "simon_says/authorizer"

begin
  require 'i18n' unless defined? I18n

  if defined? I18n
    I18n.load_path += Dir[File.join(
      File.expand_path(File.join('..', 'config', 'locales'), __dir__), '*.yml'
    )]
  end
rescue LoadError
  # do nothing
end

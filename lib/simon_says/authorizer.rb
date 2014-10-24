module SimonSays
  module Authorizer
    extend ActiveSupport::Concern

    class Denied < Exception
      def initialize(as, required, actual)
        # TODO i18n for err message (as should be singluarized with 1 flag)
        super "Access denied; #{required * ', '} role is required. Current access is #{actual * ', '}"
      end
    end

    included do
      class_attribute :default_authorization_scope
    end

    module ClassMethods
      def authenticate(scope, opts = {})
        before_filter :"authenticate_#{scope}!", filter_options(opts)
      end

      def find_and_authorize(resource, *roles)
        opts = roles.extract_options!

        before_filter(filter_options(opts)) do
          find_resource resource, opts

          authorize roles, opts unless roles.empty?
        end
      end

      def find_resource(resource, opts = {})
        before_filter(filter_options(opts)) do
          find_resource resource, opts
        end
      end

      def authorize_resource(resource, *roles)
        before_filter(filter_options(roles.extract_options!)) do
          authorize(roles, { resource: resource })
        end
      end

      def filter_options(options) # :nodoc:
        { except: options.delete(:except), only: options.delete(:only) }
      end
    end

    # @returns Primary resource found; need for +authorize+ calls
    def find_resource(resource, options = {}) # :nodoc:
      resource = resource.to_s

      scope, query = resource_scope_and_query(resource, options)
      through = options[:through] ? options[:through].to_s : nil

      assoc = through || (options[:from] ? resource.pluralize : nil)
      scope = scope.send(assoc) if assoc

      record = scope.where(query).first!

      if through
        instance_variable_set "@#{through.singularize}", record
        record = record.send(resource)
      end

      instance_variable_set "@#{resource}", record
    end


    def authorize(required = nil, options) # :nodoc:
      if through = options[:through]
        name = through.to_s.singularize.to_sym
      else
        name = options[:resource]
      end

      attr = Roleable.registry[name]
      required ||= options[attr.to_sym]

      required = [required] unless Array === required
      record = instance_variable_get("@#{name}")

      if record.nil? # must be devise scope
        record = send("current_#{name}")
        send "authenticate_#{name}!"
      end

      actual = record.send(attr)

      # actual roles must have at least
      # one required role (array intersection)
      ((required & actual).size > 0).tap do |res|
        raise Denied.new(attr, required, actual) unless res
      end
    end

    private

    def resource_scope_and_query(resource, options) # :nodoc:
      if options[:through]
        field = "#{resource}_id"

        query = { field => params[field] } if params[field]
        scope = send(self.class.default_authorization_scope)

      elsif options[:from]
        scope = instance_variable_get("@#{options[:from]}")
      else
        klass = (options[:class_name] || resource).to_s
        # TODO support array of namespaces?
        klass = "#{options[:namespace]}/#{klass}" if options[:namespace]

        scope = klass.classify.constantize
      end

      field ||= :id
      query ||= { field => params[:id] }

      return scope, query
    end
  end
end

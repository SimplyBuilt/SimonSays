module SimonSays
  module Authorizer
    extend ActiveSupport::Concern

    class Denied < StandardError
      def initialize(as, required, actual)
        # TODO i18n for err message (as should be singluarized with 1 flag)
        super "Access denied; #{required * ', '} role is required. Current access is #{actual * ', '}"
      end
    end

    included do
      class_attribute :default_authorization_scope
    end

    # Once +Authorizer+ is included these methods become
    # available to your controllers.
    module ClassMethods
      # Authentication convenience method (to keep things declarative).
      # This method just setups a +before_action+
      #
      # * +scope+ is a symbol or string and should correspond to some sort
      #   of authentication scope (ie: +authenticate_user!+)
      # * +opts+ filter options
      #
      # ====== Example
      #
      #    authenticate :user, expect: :index
      #
      def authenticate(scope, opts = {})
        before_action :"authenticate_#{scope}!", filter_options(opts)
      end

      # Find and authorize a resource.
      #
      # * +resource+ the name of resource to find
      # * +roles+ one or more role symbols
      # * the last argument may also be a filter options hash
      #
      # ====== Example
      #
      #     find_and_authorize :document, :create, :update :publish, through: :memberships
      def find_and_authorize(resource, *roles)
        opts = roles.extract_options!

        before_action(filter_options(opts)) do
          find_resource resource, opts

          authorize roles, opts unless roles.empty?
        end
      end

      # Find a resource
      #
      # * +resource+ the name of the resource to find
      # * +opts+ filter options
      def find_resource(resource, opts = {})
        before_action(filter_options(opts)) do
          find_resource resource, opts
        end
      end

      # Authorize against a given resource
      #
      # * +resource+ the name of the resource to authorize against. The
      #   resource should include +Roleable+ and define some set of
      #   roles. This method also expect the record to be available as
      #   an instance variable (which is the case if +find_resource+ is
      #   called before hand)
      # * +roles+ one or more role symbols
      # * the last argument may also be a filter options hash
      def authorize_resource(resource, *roles)
        before_action(filter_options(roles.extract_options!)) do
          authorize(roles, { resource: resource })
        end
      end

      def filter_options(options) # :nodoc:
        { except: options.delete(:except), only: options.delete(:only), prepend: options.delete(:prepend) }
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
        scope = instance_variable_get("@#{options[:from]}") || send(options[:from])

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

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
      # @param [Symbol, String] scope corresponds to some sort of authentication
      #   scope (ie: +authenticate_user!+)
      # @param [Hash] opts before_action options
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
      # @param [Symbol, String] resource name of resource to find
      # @param [Array<Symbol, String>] roles one or more role symbols or strings
      # @param [Hash] opts before_action and finder options
      # @param opts [Symbol] :find_attribute attribute resource is found by; by
      #   default, +:id+ is used
      # @param opts [Symbol] :through through model to use when finding resource
      # @param opts [Symbol] :namespace resource namespace
      # @param opts [Symbol] :through through model to use when finding resource
      #
      # @example Find and authorize with a +:through+ option
      #   find_and_authorize :document, :create, :update :publish, through: :memberships
      # @example Find a resource using a namespace
      #   find_resource :report, namespace: :admin
      def find_and_authorize(resource, *roles)
        opts = roles.extract_options!

        before_action(filter_options(opts)) do
          find_resource resource, opts

          authorize roles, opts unless roles.empty?
        end
      end

      # Find a resource
      #
      # @param [Symbol, String] resource name of resource to find
      # @param [Hash] opts before_action and finder options
      # @param opts [Symbol] :find_attribute attribute resource is found by; by
      #   default, +:id+ is used
      # @param opts [Symbol] :through through model to use when finding resource
      # @param opts [Symbol] :namespace resource namespace
      #
      # @example Find resource with a +:find_attribute+ option
      #   find_resource :image, find_attribute: :token
      def find_resource(resource, opts = {})
        before_action filter_options(opts) do
          find_resource resource, opts
        end
      end

      # Authorize against a given resource
      #
      # @param [Symbol, String] resource name of resource to find
      # @param [Array<Symbol, String>] roles one or more role symbols or strings
      # @param [Hash] opts before_action options
      #
      # @example Authorize resource
      #   authorize_resource :admin, :support
      def authorize_resource(resource, *roles)
        opts = roles.extract_options!

        before_action filter_options(opts) do
          authorize roles, { resource: resource }
        end
      end

      # @private
      def filter_options(options)
        { except: options.delete(:except), only: options.delete(:only), prepend: options.delete(:prepend) }
      end
    end

    # @private
    def find_resource(resource, options = {})
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

    # @private
    def authorize(required = nil, options)
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

    # @private
    def resource_scope_and_query(resource, options)
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

      field ||= options.fetch(:find_attribute, :id)
      query ||= { field => params[:id] }

      return scope, query
    end
  end
end

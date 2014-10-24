module SimonSays
  module Roleable
    extend ActiveSupport::Concern

    def self.registry # :nodoc:
      # "global" registry we'll use when authorizing
      @registry ||= {}
    end

    module ClassMethods
      ##
      # Provides a declarative method to introduce role based
      # access controller through a give integer mask.
      #
      # By default it'll use an attributed named +role_mask+. You can
      # use the +:as+ option to change the prefix for the +_mask+
      # attribute. This will also alter the names of the dynamically
      # generated methods.
      #
      # ===== Example
      #
      #   class User < ActiveRecord::Base
      #     include SimonSays::Roleable
      #
      #     has_roles :read, :write, :delete
      #   end
      #
      #   class Editor < ActiveRecord::Base
      #     include SimonSays::Roleable
      #
      #     has_roles :create, :update, :publish, as: :access
      #   end
      #
      # ===== Dynamic Methods
      #
      # Several methods are dynamically genreated when calling +has_roles+.
      # The methods generated include a setter, a getter and a predicate
      # method. For examples:
      #
      #   User.new.roles
      #   => []
      #
      #   User.new(roles: :read).roles
      #   => [:read]
      #
      #   User.new.tap { |u| u.roles = :write, :read }.roles
      #   => [:read, :write]
      #
      #   User.new(roles: [:read, :write]).has_roles? :read, :write
      #   => true
      #
      #   User.new(roles: :read).has_role? :read
      #   => true
      #
      # Here's an example using the +:as+ prefix option:
      #
      #   Editor.new(access: %w[create update publish]).access
      #   => [:create, :update, :publish]
      #
      #   Editor.new(access: :publish).has_access? :create
      #   => false
      #
      def has_roles *roles
        options = roles.extract_options!

        name = (options[:as] || :roles).to_s
        singular = name.singularize
        const = name.upcase

        Roleable.registry[model_name.to_s.downcase.to_sym] ||= name

        roles.map!(&:to_sym)

        class_eval <<-RUBY_EVAL, __FILE__, __LINE__
          #{const} = %i[#{roles * ' '}]

          def #{name}=(args)
            args = [args] unless Array === args
            args.map!(&:to_sym)

            self[:#{name}_mask] = (args & #{const}).map { |i| 2 ** #{const}.index(i) }.sum
          end

          def #{name}
            #{const}.reject { |i| ((#{name}_mask || 0) & 2 ** #{const}.index(i)).zero? }
          end

          def has_#{name}?(*args)
            (#{name} & args).size > 0
          end
        RUBY_EVAL

        if name != singular
          class_eval <<-RUBY_EVAL
            alias has_#{singular}? has_#{name}?
          RUBY_EVAL
        end

        # Declare a scope for finding records with a given role set
        # TODO support an array roles (must match ALL)
        scope "with_#{name}", ->(role) {
          where("(#{name}_mask & ?) > 0", 2**roles.index(role))
        }
      end
    end
  end
end

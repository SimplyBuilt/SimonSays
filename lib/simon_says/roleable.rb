module SimonSays
  module Roleable
    extend ActiveSupport::Concern

    module ClassMethods
      ##
      # Provides a declarative method to introduce role based
      # access controller through a give integer mask.
      #
      # Expects +role_mask+ to be an attribute. Can use
      # the +:as+ option to change the prefix for the +_mask+
      # attribute. This will also alter the method names.
      #
      # @example
      #   has_roles :read, :write, :delete
      #   has_roles :publish, :payment, as: :site_admin
      #
      # @overload has_roles(*roles, opts = {})
      #   @param [Array<Symbol,String>] roles list of roles
      #   @param [Hash] opts options hash
      #   @option opts [Symbol, String] :as the role mask attribute to use
      def has_roles *roles
        options = roles.extract_options!

        name = (options[:as] || :roles).to_s
        singular = name.singularize
        const = name.upcase

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

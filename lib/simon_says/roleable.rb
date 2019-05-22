module SimonSays
  module Roleable
    extend ActiveSupport::Concern

    module ClassMethods
      # Provides a declarative method to introduce role based
      # access controller through a give integer mask.
      #
      # By default it'll use an attributed named +role_mask+. You can
      # use the +:as+ option to change the prefix for the +_mask+
      # attribute. This will also alter the names of the dynamically
      # generated methods.
      #
      # Several methods are dynamically genreated when calling +has_roles+.
      # The methods generated include a setter, a getter and a predicate
      # method
      #
      # @param [Array<Symbol, String>] roles array of role symbols or strings
      # @param [Hash] opts options hash
      # @param opts [Symbol] :as alternative prefix name instead of "role"
      #
      # @example Detailed example:
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

        roles.map!(&:to_sym)

        class_eval <<-RUBY_EVAL, __FILE__, __LINE__
          #{const} = %i[#{roles * ' '}]

          def #{name}=(args)
            args = [args] unless Array === args

            args.compact!
            args.map!(&:to_sym)

            self.#{name}_mask = (args & #{const}).map { |i| 2 ** #{const}.index(i) }.sum
          end

          def #{name}
            #{const}.reject { |i| ((#{name}_mask || 0) & 2 ** #{const}.index(i)).zero? }.tap(&:freeze)
          end

          def has_#{name}?(*args)
            (#{name} & args).size > 0
          end

          def self.role_attribute_name
            :#{name}
          end
        RUBY_EVAL

        if name != singular
          class_eval <<-RUBY_EVAL
            alias has_#{singular}? has_#{name}?
          RUBY_EVAL
        end

        Roleable.define_orm_scope self, "with_#{name}" do |*args|
          clause = "#{name}_mask & ?"
          values = Roleable.cast_roles_to_ints(roles, *args)

          query = where(clause, values.shift)
          query = query.or(where(clause, values.shift)) until values.empty?
          query
        end

        Roleable.define_orm_scope self, "with_all_#{name}" do |*args|
          clause = "#{name}_mask & ?"
          values = Roleable.cast_roles_to_ints(roles, *args)

          query = where(clause, values.shift)
          query = query.where(clause, values.shift) until values.empty?
          query
        end
      end
    end

    def self.cast_roles_to_ints(defined_roles, *args)
      values = args.map do |arg|
        index = defined_roles.index(arg)
        index ? 2 ** index : nil
      end

      values.tap(&:flatten!)
    end

    def self.define_orm_scope(model, name, &block)
      if defined? ActiveRecord
        model.scope name, block
      elsif defined? Sequel
        model.dataset_module { subset name, &block }
      end
    end
  end
end

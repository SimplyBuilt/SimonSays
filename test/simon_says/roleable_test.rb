require 'test_helper'

class RoleableTest < ActiveSupport::TestCase
  setup do
    create_test_table :test_widgets do |t|
      t.integer :roles_mask, default: 0
      t.integer :access_mask, default: 0
    end

    @klass = Class.new(ActiveRecord::Base) do
      self.table_name = 'test_widgets'

      include SimonSays::Roleable

      has_roles :read, :write
    end

    @as_klass = Class.new(ActiveRecord::Base) do
      self.table_name = 'test_widgets'

      include SimonSays::Roleable

      has_roles :moderator, :support, :editor, as: :access
    end

    @instance = @klass.new
    @as_instance = @as_klass.new
  end

  test "adds constant" do
    assert_equal [:read, :write], @klass::ROLES
  end

  test "adds constant with :as option" do
    assert_equal [:moderator, :support, :editor], @as_klass::ACCESS
  end

  test "adds roles method" do
    assert @instance.respond_to?(:roles)
  end

  test "adds roles= method" do
    assert @instance.respond_to?(:roles=)
  end

  test "adds reader method with :as option" do
    assert @as_instance.respond_to?(:access)
  end

  test "adds writer method with :as option" do
    assert @as_instance.respond_to?(:access=)
  end

  test 'roles returns array of symbols' do
    @instance.roles_mask = 3

    assert_equal [:read, :write], @instance.roles
  end

  test 'roles returns array of symbols with :as option' do
    @as_instance.access_mask = 6

    assert_equal [:support, :editor], @as_instance.access
  end

  test "set single symbol" do
    @instance.roles = :read

    assert_equal 1, @instance.roles_mask
  end

  test "set single symbol with :as option" do
    @as_instance.access = :moderator

    assert_equal 1, @as_instance.access_mask
  end

  test "set single string" do
    @instance.roles = 'write'

    assert_equal 2, @instance.roles_mask
  end

  test "set single string with :as option" do
    @as_instance.access = 'support'

    assert_equal 2, @as_instance.access_mask
  end

  test "set with multi symbols" do
    @instance.roles = :read, :write

    assert_equal 3, @instance.roles_mask
  end

  test "set with multi symbols with :as option" do
    @as_instance.access = :support, :editor

    assert_equal 6, @as_instance.access_mask
  end

  test "set with multi strings" do
    @instance.roles = 'read', 'write'

    assert_equal 3, @instance.roles_mask
  end

  test "set with multi strings with :as option" do
    @as_instance.access = 'support', 'editor'

    assert_equal 6, @as_instance.access_mask
  end

  test 'set with array of strings' do
    @instance.roles = ['read', 'write']

    assert_equal 3, @instance.roles_mask
  end

  test 'set with array of strings with :as option' do
    @as_instance.access = ['support', 'editor']

    assert_equal 6, @as_instance.access_mask
  end

  test "set out order" do
    @as_instance.access = :editor, :moderator, :support

    assert_equal 7, @as_instance.access_mask
  end

  test "has_roles? without any roles" do
    assert_equal false, @instance.has_roles?(:read)
  end

  test "has_roles? with one role" do
    @instance.roles = :read

    assert_equal true, @instance.has_roles?(:read)
  end

  test "has_roles? with multiple role" do
    @instance.roles = :read, :write

    assert_equal true, @instance.has_roles?(:read, :write)
  end

  test "has_access? without any roles" do
    assert_equal false, @as_instance.has_access?(:support)
  end

  test "has_access? with one role" do
    @as_instance.access = :editor

    assert_equal true, @as_instance.has_access?(:editor)
  end

  test "has_access? with multiple role" do
    @as_instance.access = :moderator, :support

    assert_equal true, @as_instance.has_access?(:moderator, :support)
  end

  test "named scope" do
    @klass.create roles: :read
    @klass.create roles: :write

    assert_equal [1, 1], [
      @klass.with_roles(:read).count,
      @klass.with_roles(:write).count
    ]
  end

  test "named scope with :as option" do
    @as_klass.create access: :moderator
    @as_klass.create access: [:support, :editor]

    assert_equal [1, 1, 1], [
      @as_klass.with_access(:moderator).count,
      @as_klass.with_access(:editor).count,
      @as_klass.with_access(:support).count,
    ]
  end
end

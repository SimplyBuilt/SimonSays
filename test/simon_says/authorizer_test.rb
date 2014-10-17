require 'test_helper'

class AuthorizerTest < ActiveSupport::TestCase
  setup do
    @controller = Class.new(ApplicationController) do
      # These would be defined by Devise or some authenication library
      attr_accessor :current_user, :current_admin, :sites
      attr_reader :params

      def params=(params)
        @params = params.with_indifferent_access
      end

      # shortcut to read instance variables
      def [](ivar_name)
        instance_variable_get :"@#{ivar_name}"
      end

      def authenticate_admin! # dummy method
      end

      def authenticate_user! # dummy method
      end

      include SimonSays::Authorizer
    end.new

    @controller.current_user = users(:bob)
    @controller.params = { id: documents(:alpha).id }
  end

  test "find_resource" do
    @controller.find_resource :document

    assert_equal documents(:alpha), @controller[:document]
  end

  test "find_resource with class_name" do
    @controller.find_resource :document, class_name: 'document'

    assert_equal documents(:alpha), @controller[:document]
  end

  test "find_resource with default scope and through" do
    @controller.class.default_authorization_scope = :current_user
    @controller.current_user = users(:bob)

    @controller.find_resource :document, through: :memberships

    assert_equal documents(:alpha), @controller[:document]
  end

  test "find_resource with from" do
    @controller.instance_variable_set :@user, users(:bob)

    @controller.find_resource :document, from: :user

    assert_equal documents(:alpha), @controller[:document]
  end

  test "find_resource with namespace" do
    @controller.current_admin = admins(:support)
    @controller.params = { id: admin_reports(:report_one).id }

    @controller.find_resource :report, namespace: :admin

    assert_equal admin_reports(:report_one), @controller[:report]
  end

  test "find_resource raises RecordNotFound" do
    assert_raises ActiveRecord::RecordNotFound do
      @controller.params = { id: -1 }
      @controller.find_resource :document
    end
  end

  test "find_resource raises RecordNotFound with default scope and through" do
    @controller.class.default_authorization_scope = :current_user
    @controller.current_user = users(:bob)

    assert_raises ActiveRecord::RecordNotFound do
      @controller.params = { id: -1 }
      @controller.find_resource :document, through: :memberships
    end
  end

  test "find_resource raises RecordNotFound with from" do
    @controller.instance_variable_set :@user, users(:bob)

    assert_raises ActiveRecord::RecordNotFound do
      @controller.params = { id: -1 }
      @controller.find_resource :document, from: :user
    end
  end

  test "authorize with membership role" do
    @controller.instance_variable_set :@membership, documents(:alpha).memberships.first

    assert @controller.authorize(:fork, resource: :membership)
  end

  test "authorize with current_admin" do
    @controller.current_admin = admins(:support)

    assert @controller.authorize(:support, resource: :admin)
  end

  test "authorize with multiple roles" do
    @controller.instance_variable_set :@membership, documents(:alpha).memberships.first

    assert @controller.authorize([:update, :delete], resource: :membership)
  end

  test "authorize with through" do
    @controller.instance_variable_set :@membership, documents(:alpha).memberships.first

    assert @controller.authorize(:delete, through: :membership)
  end

  test "authorize invokes authentication_admin" do
    @controller.current_admin = admins(:marketing)

    @controller.expects(:authenticate_admin!).once
    @controller.authorize(:marketing, resource: :admin)
  end

  test "authorization failure single role" do
    assert_raises SimonSays::Authorizer::Denied do
      @controller.instance_variable_set :@membership, documents(:beta).memberships.first

      @controller.authorize(:delete, resource: :membership)
    end
  end

  test "authorization failire multi roles" do
    @controller.instance_variable_set :@membership, documents(:beta).memberships.first

    assert_raises SimonSays::Authorizer::Denied do
      @controller.authorize([:update, :delete], resource: :membership)
    end
  end
end


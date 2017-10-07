require 'test_helper'

class RoleableTest < ActiveSupport::TestCase
  test "adds constant" do
    assert_equal [:download, :fork, :edit, :delete], Membership::ROLES
  end

  test "adds constant with :as option" do
    assert_equal [:support, :content, :marketing], Admin::ACCESS
  end

  test "adds roles method" do
    assert_equal Membership::ROLES, memberships(:mb1).roles
  end

  test "adds reader method with :as option" do
    assert_equal Admin::ACCESS, admins(:all).access
  end

  test "set roles with multiple symbols" do
    mbr = memberships(:mb2)
    mbr.roles = :download, :fork

    assert_equal [:download, :fork], mbr.roles
  end

  test "set roles with multiple symbols with :as option" do
    adm = admins(:support)
    adm.access = :support, :marketing

    assert_equal [:support, :marketing], adm.access
  end

  test "set roles with single symbol" do
    mbr = memberships(:mb2)
    mbr.roles = :download

    assert_equal [:download], mbr.roles
  end

  test "set roles with single symbol with :as option" do
    adm = admins(:support)
    adm.access = :marketing

    assert_equal [:marketing], adm.access
  end

  test "set roles with single string" do
    mbr = memberships(:mb2)
    mbr.roles = 'download'

    assert_equal [:download], mbr.roles
  end

  test "set roles with single string with :as option" do
    adm = admins(:support)
    adm.access = 'marketing'

    assert_equal [:marketing], adm.access
  end

  test "set roles with multiple strings" do
    mbr = memberships(:mb2)
    mbr.roles = 'download', 'fork'

    assert_equal [:download, :fork], mbr.roles
  end

  test "set roles with multiples strings with :as option" do
    adm = admins(:support)
    adm.access = 'marketing', 'content'

    assert_equal [:content, :marketing], adm.access
  end

  test 'ignores unknown roles' do
    mbr = memberships(:mb2)
    mbr.roles = :download, :unknown

    assert_equal [:download], mbr.roles
  end

  test 'handles out of order roles' do
    mbr = memberships(:mb2)
    mbr.roles = Membership::ROLES.reverse

    assert_equal Membership::ROLES, mbr.roles
  end

  test "has_roles? without any roles" do
    mbr = memberships(:mb1)
    mbr.roles = nil

    assert_equal false, mbr.has_roles?(:download)
  end

  test "has_roles? with one role" do
    mbr = memberships(:mb1)
    mbr.roles = :download

    assert_equal true, mbr.has_roles?(:download)
  end

  test "has_roles? with multiple role" do
    mbr = memberships(:mb1)
    mbr.roles = :download, :fork, :edit

    assert_equal true, mbr.has_roles?(:download, :fork, :edit)
  end

  test "has_access? without any roles" do
    adm = admins(:support)
    adm.access = nil

    assert_equal false, adm.has_access?(:support)
  end

  test "has_access? with one role" do
    adm = admins(:support)
    adm.access = :marketing

    assert_equal true, adm.has_access?(:marketing)
  end

  test "has_access? with multiple role" do
    adm = admins(:support)
    adm.access = :support, :content, :marketing

    assert_equal true, adm.has_access?(:support, :content, :marketing)
  end

  test "named scope with_roles" do
    assert_equal [2, 1], [
      Membership.with_roles(:download).count,
      Membership.with_roles(:delete).count
    ]
  end

  test "named scope with_access" do
    assert_equal [2, 2, 2], [
      Admin.with_access(:marketing).count,
      Admin.with_access(:content).count,
      Admin.with_access(:support).count
    ]
  end

  test "Membership defines role_attribute_name" do
    assert_equal :roles, Membership.role_attribute_name
  end

  test "Admin defines role_attribute_name" do
    assert_equal :access, Admin.role_attribute_name
  end
end

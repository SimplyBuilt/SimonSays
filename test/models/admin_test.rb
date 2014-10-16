require 'test_helper'

class AdminModelTest < ActiveSupport::TestCase
  setup do
    @admin = Admin.new(email: 'bob@admins.com', access_mask: 0)
  end

  # TODO are these even needed
  #      the roleable_tests do a good job covering these aspects

  test "assigning a role" do
    @admin.access = :support

    assert_equal [:support], @admin.access
  end

  test "assinging multiple roles" do
    @admin.access = [:support, :marketing]

    assert_equal [:support, :marketing], @admin.access
  end
end

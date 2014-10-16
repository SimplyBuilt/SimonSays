require 'test_helper'

class AdminModelTest < ActiveSupport::TestCase
  setup do
    @admin = Admin.new(email: 'bob@admins.com', access_mask: 0)
  end

  test "Admin is in registry" do
    assert_includes SimonSays::Roleable.registry, 'Admin'
  end
end

require 'test_helper'

class AdminModelTest < ActiveSupport::TestCase
  test "Admin is in registry" do
    assert_includes SimonSays::Roleable.registry, :admin
  end
end

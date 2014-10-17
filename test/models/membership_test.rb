require 'test_helper'

class MembershipModelTest < ActiveSupport::TestCase
  test "Membership is in registry" do
    assert_includes SimonSays::Roleable.registry, :membership
  end
end

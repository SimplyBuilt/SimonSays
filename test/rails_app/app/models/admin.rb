class Admin < ApplicationRecord
  include SimonSays::Roleable

  has_roles :support, :content, :marketing, as: :access
end

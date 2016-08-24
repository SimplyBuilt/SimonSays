class Membership < ApplicationRecord
  include SimonSays::Roleable

  belongs_to :user
  belongs_to :document

  has_roles :download, :fork, :edit, :delete
end

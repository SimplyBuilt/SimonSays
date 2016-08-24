class User < ApplicationRecord
  has_many :memberships
  has_many :documents, through: :memberships
end

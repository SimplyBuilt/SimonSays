class User < ActiveRecord::Base
  has_many :memberships
  has_many :documents, through: :memberships
end

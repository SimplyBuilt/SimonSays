class Admin < ActiveRecord::Base
  include SimonSays::Roleable

  has_many :reports

  has_roles :support, :content, :marketing, as: :access
end

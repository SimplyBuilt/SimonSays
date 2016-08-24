class Image < ApplicationRecord
  has_secure_token

  def to_param
    token
  end
end

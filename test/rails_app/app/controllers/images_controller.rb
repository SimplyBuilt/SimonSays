class ImagesController < ApplicationController
  respond_to :json

  authenticate :user

  find_resource :image, find_attribute: :token, only: :show # any role

  def show
    respond_with @image
  end
end

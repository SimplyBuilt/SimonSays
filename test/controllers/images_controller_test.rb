require 'test_helper'

class ImagesControllerTest < ActionController::TestCase
  setup do
    @image = images(:image_one)

    @controller.current_admin = users(:bob)
  end

  test 'get show with correct id parameter' do
    get :show, params: { id: @image.token }, format: :json

    assert_response :success
  end

  test 'get show with incorrect id parameter' do
    assert_raises ActiveRecord::RecordNotFound do
      get :show, params: { id: @image.id }, format: :json
    end
  end
end

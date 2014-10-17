require 'test_helper'

class DocumentsControllerTest < ActionController::TestCase
  setup do
    @alpha = documents(:alpha)
    @beta  = documents(:beta)

    @bob = users(:bob)
    @jim = users(:jim)
  end

  def as_bob!
    @controller.current_user = @bob
  end

  def as_jim!
    @controller.current_user = @jim
  end

  test "show" do
    as_bob!

    get :show, id: @alpha.id, format: :json

    refute_nil assigns(:document)
    assert_response :success
  end

  test "show without through relationship" do
    as_jim!

    assert_raises ActiveRecord::RecordNotFound do
      get :show, id: @alpha.id, format: :json
    end
  end

  test "update with access" do
    as_bob!

    patch :update, id: @alpha.id, document: { title: 'Test' }, format: :json

    refute_nil assigns(:document)
    assert_response :success
  end

  test "update without access" do
    as_bob!

    assert_raises SimonSays::Authorizer::Denied do
      patch :update, id: @beta.id, document: { title: 'Test' }, format: :json
    end
  end

  test "update without through relationship" do
    as_jim!

    assert_raises ActiveRecord::RecordNotFound do
      patch :update, id: @alpha.id, document: { title: 'Test' }, format: :json
    end
  end

  test "destroy with access" do
    as_bob!

    assert_difference 'Document.count', -1 do
      delete :destroy, id: @alpha.id, format: :json
    end

    refute_nil assigns(:document)
  end

  test "destroy without access" do
    as_bob!

    assert_raises SimonSays::Authorizer::Denied do
      delete :destroy, id: @beta.id, format: :json
    end
  end

  test "destroy without through relationship" do
    as_jim!

    assert_raises ActiveRecord::RecordNotFound do
      delete :destroy, id: @beta.id, format: :json
    end
  end
end

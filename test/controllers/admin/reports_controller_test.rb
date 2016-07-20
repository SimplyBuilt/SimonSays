require 'test_helper'

class Admin::ReportsControllerTest < ActionController::TestCase
  setup do
    @support = admins(:support)
    @marketing = admins(:marketing)
  end

  test "index with access" do
    @controller.current_admin = @support

    get :index, params: { format: :json }

    assert_response :success
  end

  test "index without access" do
    @controller.current_admin = @marketing

    assert_raises SimonSays::Authorizer::Denied do
      get :index, params: { format: :json }
    end
  end

  test "create with access" do
    @controller.current_admin = @support

    assert_difference 'Admin::Report.count' do
      post :create, params: { report: { title: 'Test' }, format: :json }
    end
  end

  test "create without access" do
    @controller.current_admin = @marketing

    assert_raises SimonSays::Authorizer::Denied do
      post :create, params: { report: { title: 'Test' }, format: :json }
    end
  end

  test "show with access" do
    @controller.current_admin = @support

    get :show, params: { id: admin_reports(:report_one), format: :json }

    assert_response :success
  end

  test "show without access" do
    @controller.current_admin = @marketing

    assert_raises SimonSays::Authorizer::Denied do
      get :show, params: { id: admin_reports(:report_one), format: :json }
    end
  end

  test "update with access" do
    @controller.current_admin = @support

    patch :show, params: { id: admin_reports(:report_one), report: { title: 'Test' }, format: :json }

    assert_response :success
  end

  test "update without access" do
    @controller.current_admin = @marketing

    assert_raises SimonSays::Authorizer::Denied do
      patch :show, params: { id: admin_reports(:report_one), report: { title: 'Test' }, format: :json }
    end
  end

  test "destroy with access" do
    @controller.current_admin = @support

    assert_difference 'Admin::Report.count', -1 do
      delete :destroy, params: { id: admin_reports(:report_one), format: :json }
    end
  end

  test "destroy without access" do
    @controller.current_admin = @marketing

    assert_raises SimonSays::Authorizer::Denied do
      delete :destroy, params: { id: admin_reports(:report_one), format: :json }
    end
  end
end

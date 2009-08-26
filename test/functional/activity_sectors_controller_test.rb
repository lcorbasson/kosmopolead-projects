require 'test_helper'

class ActivitySectorsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:activity_sectors)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_activity_sector
    assert_difference('ActivitySector.count') do
      post :create, :activity_sector => { }
    end

    assert_redirected_to activity_sector_path(assigns(:activity_sector))
  end

  def test_should_show_activity_sector
    get :show, :id => activity_sectors(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => activity_sectors(:one).id
    assert_response :success
  end

  def test_should_update_activity_sector
    put :update, :id => activity_sectors(:one).id, :activity_sector => { }
    assert_redirected_to activity_sector_path(assigns(:activity_sector))
  end

  def test_should_destroy_activity_sector
    assert_difference('ActivitySector.count', -1) do
      delete :destroy, :id => activity_sectors(:one).id
    end

    assert_redirected_to activity_sectors_path
  end
end

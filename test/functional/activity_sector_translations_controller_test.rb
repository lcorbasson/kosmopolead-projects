require 'test_helper'

class ActivitySectorTranslationsControllerTest < ActionController::TestCase
  def test_should_get_index
    get :index
    assert_response :success
    assert_not_nil assigns(:activity_sector_translations)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end

  def test_should_create_activity_sector_translation
    assert_difference('ActivitySectorTranslation.count') do
      post :create, :activity_sector_translation => { }
    end

    assert_redirected_to activity_sector_translation_path(assigns(:activity_sector_translation))
  end

  def test_should_show_activity_sector_translation
    get :show, :id => activity_sector_translations(:one).id
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => activity_sector_translations(:one).id
    assert_response :success
  end

  def test_should_update_activity_sector_translation
    put :update, :id => activity_sector_translations(:one).id, :activity_sector_translation => { }
    assert_redirected_to activity_sector_translation_path(assigns(:activity_sector_translation))
  end

  def test_should_destroy_activity_sector_translation
    assert_difference('ActivitySectorTranslation.count', -1) do
      delete :destroy, :id => activity_sector_translations(:one).id
    end

    assert_redirected_to activity_sector_translations_path
  end
end

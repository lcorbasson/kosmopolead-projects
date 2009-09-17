class ActivitySectorTranslationsController < ApplicationController
  # GET /activity_sector_translations
  # GET /activity_sector_translations.xml
  layout 'base'
    menu_item :admin
  
  def index
    @activity_sector = ActivitySector.find(params[:activity_sector_id])
    @activity_sector_translations = @activity_sector.activity_sector_translations
  end

  # GET /activity_sector_translations/new
  # GET /activity_sector_translations/new.xml
  def new
    @activity_sector = ActivitySector.find(params[:activity_sector_id])
    @activity_sector_translation = @activity_sector.activity_sector_translations.build
  end

  # GET /activity_sector_translations/1/edit
  def edit
    @activity_sector = ActivitySector.find(params[:activity_sector_id])
    @activity_sector_translation = @activity_sector.activity_sector_translations.find(params[:id])
  end

  # POST /activity_sector_translations
  # POST /activity_sector_translations.xml
  def create
    @activity_sector = ActivitySector.find(params[:activity_sector_id])
    @activity_sector_translation = @activity_sector.activity_sector_translations.new(params[:activity_sector_translation])

    if @activity_sector_translation.save
      flash[:notice] = l(:notice_successful_create)
      redirect_to activity_sector_path(@activity_sector)
    else
      render :action => "new"
    end
  end

  # PUT /activity_sector_translations/1
  # PUT /activity_sector_translations/1.xml
  def update
    @activity_sector = ActivitySector.find(params[:activity_sector_id])
    @activity_sector_translation = ActivitySectorTranslation.find(params[:id])

    if @activity_sector_translation.update_attributes(params[:activity_sector_translation])
      flash[:notice] = l(:notice_successful_update)
      redirect_to activity_sector_path(@activity_sector)
    else
      render :action => "edit"
    end
  end

  # DELETE /activity_sector_translations/1
  # DELETE /activity_sector_translations/1.xml
  def destroy
    @activity_sector = ActivitySector.find(params[:activity_sector_id])
    @activity_sector_translation = ActivitySectorTranslation.find(params[:id])
    @activity_sector_translation.destroy

    redirect_to(activity_sector_path(@activity_sector))
  end
end

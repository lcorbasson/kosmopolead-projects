class ActivitySectorsController < ApplicationController
  # GET /activity_sectors
  # GET /activity_sectors.xml
  layout 'base'

  def index
    @activity_sectors = ActivitySector.find(:all)
#    if params[:local]
#      @activity_sector_translations = ActivitySectorTranslation.all(:all, :conditions => {:local => params[:local]})
#    else
#      @activity_sector_translations = ActivitySectorTranslation.all(:all, :conditions => {:local => current_language.to_s })
#    end
  end

  # GET /activity_sectors/1
  # GET /activity_sectors/1.xml
  def show
    @activity_sector = ActivitySector.find(params[:id])
    @activity_sector_translationss = ActivitySectorTranslation.find(:all, :conditions => {:activity_sector_id => @activity_sector.id})

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activity_sector }
    end
  end

  # GET /activity_sectors/new
  # GET /activity_sectors/new.xml
  def new
    @activity_sector = ActivitySector.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity_sector }
    end
  end

  # GET /activity_sectors/1/edit
  def edit
    @activity_sector = ActivitySector.find(params[:id])
  end

  # POST /activity_sectors
  # POST /activity_sectors.xml
  def create
    @activity_sector = ActivitySector.new(params[:activity_sector])
    respond_to do |format|

      if @activity_sector.save
        @activity_sectors = ActivitySector.find(:all)
        flash[:notice] = 'ActivitySector was successfully created.'
        format.js  {
          render :update do |page|
            page.replace_html "activity_sectors", :partial => 'activity_sectors/index'
          end
        }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /activity_sectors/1
  # PUT /activity_sectors/1.xml
  def update
    @activity_sector = ActivitySector.find(params[:id])

    respond_to do |format|
      if @activity_sector.update_attributes(params[:activity_sector])
        flash[:notice] = 'ActivitySector was successfully updated.'
        format.html { redirect_to(@activity_sector) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @activity_sector.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /activity_sectors/1
  # DELETE /activity_sectors/1.xml
  def destroy
    @activity_sector = ActivitySector.find(params[:id])
    @activity_sector.destroy

    respond_to do |format|
      format.html { redirect_to(activity_sectors_url) }
      format.xml  { head :ok }
    end
  end

  def f_translation=(attributes)
      # Process the attributes hash
  end

  def sector_translations
    @activity_sectors = ActivitySector.find(:all)
    #@activity_sector_translations = ActivitySectorTranslation.all(:all, :conditions => {:local => params[:local]})
    @local =  params[:local]

    render :layout=>false
   
  end
end

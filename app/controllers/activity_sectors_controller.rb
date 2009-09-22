class ActivitySectorsController < ApplicationController
  before_filter :require_admin, :require_community
  # GET /activity_sectors
  # GET /activity_sectors.xml
  layout 'base'
  menu_item :admin


  def index
    @activity_sectors = @community.activity_sectors
#    if params[:local]
#      @activity_sector_translations = ActivitySectorTranslation.all(:all, :conditions => {:local => params[:local]})
#    else
#      @activity_sector_translations = ActivitySectorTranslation.all(:all, :conditions => {:local => current_language.to_s })
#    end
  end

  # GET /activity_sectors/1
  # GET /activity_sectors/1.xml
  def show
    @activity_sector = @community.activity_sectors.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @activity_sector }
    end
  end

  # GET /activity_sectors/new
  # GET /activity_sectors/new.xml
  def new
    @activity_sector = @community.activity_sectors.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @activity_sector }
    end
  end

  # GET /activity_sectors/1/edit
  def edit
    @activity_sector = @community.activity_sectors.find(params[:id])
  end

  # POST /activity_sectors
  # POST /activity_sectors.xml
  def create
    @activity_sector = @community.activity_sectors.build(params[:activity_sector])

    if @activity_sector.save
      @activity_sectors = @community.activity_sectors
      respond_to do |format|
       format.js{
          render :update do |page|
            page << display_message_error(l(:notice_successful_create), "fieldNotice")
            page.replace_html "activity_sectors", :partial => 'activity_sectors/index'
         end
       }
      end
    else
      respond_to do |format|
       format.js{
          render :update do |page|
            page << display_message_error("plop" , "fieldError")
         end
       }
      end
      format.html { render :action => "new" }
    end
  end

  # PUT /activity_sectors/1
  # PUT /activity_sectors/1.xml
  def update
    @activity_sector = @community.activity_sectors.find(params[:id])

    respond_to do |format|
      if @activity_sector.update_attributes(params[:activity_sector])
        flash[:notice] = l(:notice_successful_update)
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
    @activity_sector = @community.activity_sectors.find(params[:id])
    @activity_sector.destroy
    respond_to do |format|
      format.html { redirect_to(activity_sectors_url) }
    end
  end

  def sector_translations
    @activity_sectors = @community.activity_sectors
    #@activity_sector_translations = ActivitySectorTranslation.all(:all, :conditions => {:local => params[:local]})
    @local =  params[:local]

    render :layout=>false
   
  end
end

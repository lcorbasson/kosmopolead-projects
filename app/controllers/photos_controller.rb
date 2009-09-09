class PhotosController < ApplicationController
  before_filter :find_project

  def index
   @photos = @gallery.photos
   render :layout=>false
  end

  def new
    @photo = Photo.new
    @photo.gallery_id = @gallery.id
    render :layout=>false
  end

  def create
    @photo = Photo.new(params[:photo])
    @photo.gallery_id = @gallery.id
    respond_to do |format|
      format.html { redirect_to :action => :index,:controller=>:projects}
      format.js { render(:update) {|page| 
            if @photo.save
              page.replace_html "photo_index", :partial => 'photos/index',:locals=>{:photos=>@gallery.photos}
            else
            page << display_message_error(@photo, "fieldError")
            end
          } }
    end
  end

  def destroy
    # Make sure association callbacks are called
    @photo = Photo.find(params[:id])
    @photo.destroy
    respond_to do |format|
        format.js {
          render(:update) {|page|
                page.replace_html "photo_index", :partial => 'photos/index',:locals=>{:photos=>@gallery.photos}
               }
         }
     end
  rescue ::ActionController::RedirectBackError
    redirect_to :controller => 'projects', :action => 'show', :id => @project
  end


private

  def find_project
    @project = Project.find_by_identifier(params[:project_id])
    @gallery = Gallery.find(params[:gallery_id])
  end

end
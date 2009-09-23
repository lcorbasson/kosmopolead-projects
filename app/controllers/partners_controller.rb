class PartnersController < ApplicationController
  before_filter :require_admin, :require_community
  menu_item :admin

  helper :sort
  include SortHelper
  helper :custom_fields
  include CustomFieldsHelper


  def index
    sort_init 'name', 'asc'
    sort_update %w(name created_at)

    @partner_count = @community.partners.count
    @partner_pages = Paginator.new self, @partner_count,
								per_page_option,
								params['page']
    @partners = @community.partners.all :order => sort_clause,
						:limit  =>  @partner_pages.items_per_page,
						:offset =>  @partner_pages.current.offset
  end

  def add
    if request.get?
      @partner = Partner.new()
    else
      @partner = @community.partners.build(params[:partner])
      if @partner.save      
        flash[:notice] = l(:notice_successful_create)
        redirect_to :action => 'index'
      end
    end 
  end

  def edit
    @partner = @community.partners.find(params[:id])
    if request.post?    
      @partner.attributes = params[:partner]     
      if @partner.save  
        flash[:notice] = l(:notice_successful_update)       
        redirect_to(url_for(:action => 'index', :page => params[:page]))
      end
    end
  
  end


end
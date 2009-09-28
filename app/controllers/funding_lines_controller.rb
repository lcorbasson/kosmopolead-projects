class FundingLinesController < ApplicationController

   helper :sort
  include SortHelper

  def new
    @project = Project.find_by_identifier(params[:project_id])
    @funding_line = FundingLine.new
    render :layout=>false
  end

  def edit
    @funding_line = FundingLine.find(params[:id])
    respond_to do |format|
      format.js { render(:update) {|page| page.replace_html "edit_funding", :partial => 'funding_lines/edit'} }
    end
  end

  def update
    @funding_line = FundingLine.find(params[:id])
    @project = Project.find_by_identifier(params[:project_id])    
    show_funding
    respond_to do |format|
        format.js { render(:update) {|page|
                        if @funding_line.update_attributes(params[:funding_line])
                            @funding_line = FundingLine.new
                            @funding_lines = @project.funding_lines
                            page.replace_html "tab-content-funding", :partial => 'projects/show/funding'
                            page << display_message_error(l(:notice_successful_update), "fieldNotice")
                            page << "Element.scrollTo('content_wrapper');"
                        else
                          page << display_message_error(@funding_line, "fieldError")
                          page << "Element.scrollTo('content_wrapper');"
                        end
                    }
         }
    end       
  end

  def create
    @funding_line = FundingLine.new(params[:funding_line])
    @funding_line.agreed_on = params[:funding_line][:agreed_on]
    @funding_line.released_on = params[:funding_line][:released_on]
    @project = Project.find_by_identifier(params[:project_id])
    @funding_line.project_id = @project.id   
    show_funding
    respond_to do |format|
        format.js { render(:update) {|page|
              if @funding_line.save
                @funding_line = FundingLine.new
                 @funding_lines = @project.funding_lines
                  page.replace_html "tab-content-funding", :partial => 'projects/show/funding'
                  page << display_message_error(l(:notice_successful_create), "fieldNotice")
                  page << "Element.scrollTo('content_wrapper');"
              else
                  page << display_message_error(@funding_line, "fieldError")
                  page << "Element.scrollTo('content_wrapper');"
              end
              }
        }
    end
  end


  def destroy
    @funding_line = FundingLine.find(params[:id])
    if @funding_line.destroy
       @project = Project.find_by_identifier(params[:project_id])
       @funding_line = FundingLine.new      
       @funding_lines = @project.funding_lines
       @funding_lines = @project.funding_lines
       respond_to do |format|
          format.js { render(:update) {|page|
              page.replace_html "tab-content-funding", :partial => 'projects/show/funding'
              page << display_message_error(l(:notice_successful_destroy), "fieldNotice")
              page << "Element.scrollTo('content_wrapper');"
             }

         }
      end
    else
        page << display_message_error(@funding_line, "fieldError")
        page << "Element.scrollTo('content_wrapper');"
    end
  end

  private

  def show_funding
    sort_init 'aap', 'asc'
    sort_update %w(aap backer backer_correspondent asked_amount funding_type agreed_on agreed_on released_on released_amount)


      @funding_line_count = @project.funding_lines.count
      @funding_line_pages = Paginator.new self, @funding_line_count,
								per_page_option,
								params['page']
      @funding_lines = FundingLine.find :all, :order => sort_clause,
                    :conditions=>["project_id = ?",@project.id],
						:limit  =>  @funding_line_pages.items_per_page,
						:offset =>  @funding_line_pages.current.offset
  end
  
end
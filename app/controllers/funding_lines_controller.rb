class FundingLinesController < ApplicationController

  def new
    @project = Project.find_by_identifier(params[:project_id])
    case params[:oper]
      when "add"
        @funding_line = FundingLine.create(
          :aap=>params[:aap],
          :financeur=>params[:financeur],
          :correspondant_financeur=>params[:correspondant],
          :montant_demande=>params[:montant_demande],
          :funding_type=>params[:funding_type],
          :date_accord=>params[:date_accord],
          :montant_accorde=>params[:montant_accorde],
          :date_liberation=>params[:date_liberation],
          :montant_libere=>params[:montant_libere],
          :project_id=>@project.id
          )
      when "del"
        @funding_line = FundingLine.find(params[:id])
        @funding_line.destroy
      when "edit"
        @funding_line = FundingLine.find(params[:id])
        @funding_line.update_attributes(
          :aap=>params[:aap],
          :financeur=>params[:financeur],
          :correspondant_financeur=>params[:correspondant],
          :montant_demande=>params[:montant_demande],
          :funding_type=>params[:funding_type],
          :date_accord=>params[:date_accord],
          :montant_accorde=>params[:montant_accorde],
          :date_liberation=>params[:date_liberation],
          :montant_libere=>params[:montant_libere],
          :project_id=>@project.id)
     end
     respond_to do |format|      
      format.js { render(:update) {|page| page.replace_html "funding", :partial => 'projects/funding'} }
    end
  end
  
end
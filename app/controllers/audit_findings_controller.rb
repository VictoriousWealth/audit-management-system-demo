class AuditFindingsController < ApplicationController
  before_action :set_audit
  before_action :set_report, only: [:new, :create]


  def new
    @audit = Audit.find(params[:audit_id])
    @audit_finding = AuditFinding.new # Use OpenStruct as a placeholder object
  end

  def create
    session[:audit_findings] ||= []
    # Check if the session already has findings
    session[:audit_findings] << {
      description: params[:audit_finding][:description],
      risk_level:  params[:audit_finding][:risk_level].downcase,
      category:    params[:audit_finding][:category].downcase,
      due_date:    params[:audit_finding][:due_date]
    }

    redirect_to new_audit_report_path(@audit), notice: "Finding added (not saved yet)"
  end

  def destroy
    # Find the description of the finding to be deleted from the params
    description_to_delete = params[:description]
    
    # Remove the finding from the session that matches the description
    session[:audit_findings] = session[:audit_findings].reject do |finding|
      finding[:description] == description_to_delete
    end
    
    # Redirect or respond to indicate the deletion is complete
    redirect_to new_audit_report_path(@audit), notice: 'Finding removed.'
  end


  private

  def set_audit
    @audit = Audit.find(params[:audit_id])
  end

  def set_report
    @report = @audit.report || @audit.build_report # Build a new report if it doesn't exist
  end

  def audit_finding_params
    params.require(:audit_finding).permit(:description, :category, :risk_level, :due_date, :temp_token).tap do |permitted|
      permitted[:risk_level] = permitted[:risk_level]&.downcase
      permitted[:category]   = permitted[:category]&.downcase
    end
    
  end
end

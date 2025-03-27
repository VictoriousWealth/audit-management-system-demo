class LettersController < ApplicationController
  before_action :set_audit, only: [:audit_request_letter_create, :audit_request_letter_view]
  before_action :set_audit_detail, only: [:audit_request_letter_create, :audit_request_letter_view]

  # GET /letters/create-audit-request-letter
  def audit_request_letter_create
    @today_date = Date.today.strftime("%d/%m/%Y")
    
    @auditor_names = []

    auditor_ids = AuditAssignment.where(audit_id: @audit.id, role: 1).pluck(:user_id)
    auditor_ids.each do |id|
      auditor = User.find(id)
      @auditor_names.push("#{auditor.first_name} #{auditor.last_name}")
    end
    
    lead_auditor_id = AuditAssignment.where(audit_id: @audit.id, role: 0).pluck(:user_id).first
    @lead_auditor = User.find(lead_auditor_id)

    render 'pages/request-letters/audit-request-letter-create'
  end

  def audit_request_letter_view
      render 'pages/letters/audit-request-letter-view'
  end

  private
    def set_audit 
      @audit = Audit.find(params[:id])
    end
    def set_audit_detail
      @audit_detail = AuditDetail.find_by(audit_id: @audit.id)
    end
end
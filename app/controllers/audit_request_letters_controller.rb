class AuditRequestLettersController < ApplicationController
  before_action :set_audit, :set_audit_detail
  skip_before_action :verify_authenticity_token, only: [:save_audit_letter] 

  # Check if the user is authorized to perform actions on the audit request letter
  authorize_resource

  # GET /audit/audit_id/create-audit-request-letter
  def new
    @audit_request_letter = AuditRequestLetter.find_or_initialize_by(audit: @audit)
    @today_date = Date.today.strftime("%d/%m/%Y")
  end
    
  # POST /audit/audit_id/create-audit-request-letter
  def create
    @today_date = Date.today.strftime("%d/%m/%Y")

    @audit_request_letter = AuditRequestLetter.find_or_initialize_by(audit: @audit)
    @audit_request_letter.user = current_user

    @audit_request_letter.content = {
      company: {
        name: @company.name,
        city: @company.city,
        postcode: @company.postcode,
        street_name: @company.street_name
      },
      audit: {
        id: @audit.id,
        reference: @audit.id.to_s.rjust(6, "0"),
        scope: params[:audit_scope],
        purpose: params[:audit_purpose],
        objectives: params[:audit_objectives],
        location: params[:audit_location],
        criteria: params[:audit_criteria],
        boundaries: params[:audit_boundaries],
      },
      assignments: {
        lead_auditor: @lead_auditor,
        auditee: @auditee,
        assigned_auditors: @assigned_auditors
      },
      dates: {
        scheduled_start_date: @audit.scheduled_start_date.strftime("%d/%m/%Y"),
        scheduled_end_date: @audit.scheduled_end_date.strftime("%d/%m/%Y")
      }
    }.to_json

    if @audit_request_letter.save
      redirect_to preview_audit_audit_request_letters_path(@audit), notice: "Audit Request Letter created successfully."
    else
      render :new
    end
  end


  # GET /audit/audit_id/create-audit-request-letter/audit_request_letter_id/preview/
  def preview
    @audit_request_letter = AuditRequestLetter.find_by(audit: @audit)
    if @audit_request_letter.nil?
      redirect_to new_audit_audit_request_letters_path(@audit), alert: "Audit Request Letter not found."
    end
    # Get the audit request letter content
    @content = @audit_request_letter.content
    @content = JSON.parse(@audit_request_letter.content || "{}")
  end

  # GET /audit/audit_id/audit-request-letter
  def show
    @audit_request_letter = AuditRequestLetter.find_by(audit: @audit)
    if @audit_request_letter.present?
      @content = @audit_request_letter.content
      @content = JSON.parse(@audit_request_letter.content || "{}")

      render :show
    else
      redirect_to new_audit_audit_request_letters_path(@audit), alert: "Audit Request Letter not found."
    end
  end

  # POST /audit/audit_id/audit-request-letter/verify
  def verify
    @audit_request_letter = AuditRequestLetter.find_by(audit: @audit)
  
    if @audit_request_letter.present?
      @audit_request_letter.time_of_verification = Time.current
      @audit_request_letter.user = current_user
  
      if @audit_request_letter.save
        redirect_to audit_audit_request_letters_path(@audit), notice: "Audit Request Letter verified successfully."
      else
        redirect_to new_audit_audit_request_letters_path(@audit), alert: "Failed to verify Audit Request Letter."
      end
    else
      redirect_to new_audit_audit_request_letters_path(@audit), alert: "Audit Request Letter not found."
    end
  end

  # DELETE /audit/audit_id/create-audit-request-letter
  def destroy
    @audit_request_letter = AuditRequestLetter.find_by(audit: @audit)
    if @audit_request_letter.destroy
      # TODO change this to redirect to the audit page when integrated
      redirect_to new_audit_audit_request_letters_path(@audit), notice: "Audit Request Letter was successfully destroyed.", status: :see_other
    else
      redirect_to audit_request_letters_path(@audit), alert: "Unable to destroy letter."
    end
  end

  private
    def set_audit
      raise "Missing audit_id in params" unless params[:audit_id].present?
      @audit = Audit.includes(:audit_detail, :company).find(params[:audit_id])
      raise "Audit not found" unless @audit.present?
    end

    def set_audit_detail
      raise "Missing audit_detail_id in params" unless AuditDetail.find_by(audit: @audit).present?
      @audit_detail = AuditDetail.find_by(audit: @audit)
      audit_assignments = @audit.audit_assignments.includes(:user)
  
      # Get the company
      @company = @audit.company
  
      # Get the auditee
      @auditee = audit_assignments.find_by(role: :auditee)&.user 
  
      # Creates an array of all auditors
      @assigned_auditors = audit_assignments.where(role: :auditor).map(&:user) 
      # Get the lead auditor
      @lead_auditor = audit_assignments.find_by(role: :lead_auditor)&.user 
      # Get the audit detail
      @audit_scope = @audit_detail.scope
      @audit_purpose = @audit_detail.purpose
      @audit_objectives = @audit_detail.objectives
      @audit_boundaries = @audit_detail.boundaries

      # Array of all standards for audit (The criteria of the audit)
      @audit_criteria = AuditStandard.where(audit_detail: @audit_detail).map(&:standard).join(", ")  
    end
end
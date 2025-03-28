class CreateEditAuditsController < ApplicationController
  def new
    @final_outcomes = ["pass", "fail", "nil"]
    @statuses = ["not_started", "in_progress", "pending_review", "completed", "cancelled"]
    @companies = Company.all
    @auditees = User.auditee
    @audit_types = ["internal", "external"]
    @auditors = User.auditor
    @users = User.all
    @standards = AuditStandard.all
    @audit_details = AuditDetail.all

    #  need to create audit, audit_assignment, audit detail, audit standards based on params
  end

  def create
    # If "Close Audit" was clicked, do not save anything
    if params[:commit] == "Close Audit"
      redirect_to audits_path, notice: "Audit creation cancelled. No data was saved."
      return
    end

    @final_outcomes = ["pass", "fail", "nil"]
    @statuses = ["not_started", "in_progress", "pending_review", "completed", "cancelled"]
    @companies = Company.all
    @auditees = User.auditee
    @audit_types = ["internal", "external"]
    @auditors = User.auditor
    @users = User.all
    @standards = AuditStandard.all
    @audit_details = AuditDetail.all

    required_fields = [
      params.dig(:company, :id),
      params.dig(:audit_assignment, :auditee),
      params.dig(:audit_assignment, :lead_auditor),
      params.dig(:audit, :scheduled_start_date),
      params.dig(:audit, :scheduled_end_date),
      params.dig(:audit, :audit_type),
      params.dig(:audit_detail, :scope),
      params.dig(:audit_detail, :objectives),
      params.dig(:audit_detail, :purpose),
      params.dig(:audit_detail, :boundaries)
    ]

    unless required_fields.all?(&:present?)
      flash.now[:alert] = "Please fill in all required fields before submitting."
      render :new
      return
    end
    
    # Proceed with saving logic below...
    # Find the company
    company_id = params.dig(:company, :id)
    @company = Company.find_by(id: company_id)
  
    # Create the Audit
    @audit = Audit.new(
      company_id: company_id,
      audit_type: params.dig(:audit, :audit_type),
      scheduled_start_date: params.dig(:audit, :scheduled_start_date),
      scheduled_end_date: params.dig(:audit, :scheduled_end_date),
      actual_start_date: params.dig(:audit, :actual_start_date),
      actual_end_date: params.dig(:audit, :actual_end_date)
    )
  
    if @audit.save
      # Create AuditDetail
      audit_detail = @audit.build_audit_detail(
        scope: params.dig(:audit_detail, :scope),
        objectives: params.dig(:audit_detail, :objectives),
        purpose: params.dig(:audit_detail, :purpose),
        boundaries: params.dig(:audit_detail, :boundaries)
      )
      audit_detail.save
  
      # Create AuditStandards
      standards = params[:audit_standard][:standard] rescue []
      standards.each do |std|
        audit_detail.audit_standards.create(standard: std)
      end
  
      # Create AuditAssignments
      if (lead_id = params.dig(:audit_assignment, :lead_auditor)).present?
        @audit.audit_assignments.create(user_id: lead_id, role: :lead_auditor, status: :assigned)
      end
  
      if params[:audit_assignment][:support_auditor].present?
        params[:audit_assignment][:support_auditor].reject(&:blank?).each do |id|
          @audit.audit_assignments.create(user_id: id, role: :auditor, status: :assigned)
        end
      end      
  
      if params[:audit_assignment][:sme].present?
        params[:audit_assignment][:sme].reject(&:blank?).each do |id|
          @audit.audit_assignments.create(user_id: id, role: :sme, status: :assigned)
        end
      end      
  
      if (auditee_id = params.dig(:audit_assignment, :auditee)).present?
        @audit.audit_assignments.create(user_id: auditee_id, role: :auditee, status: :assigned)
      end
  
      redirect_to edit_create_edit_audit_path(@audit), notice: 'Audit created successfully.'
    else
      render :new
    end
  end


  def edit
    @audit = Audit.find(params[:id])
    @company_id = @audit.company_id
    @audit_type = @audit.audit_type
    @scheduled_start = @audit.scheduled_start_date
    @scheduled_end = @audit.scheduled_end_date
    @actual_start = @audit.actual_start_date
    @actual_end = @audit.actual_end_date
    
    @audit_detail = AuditDetail.find_by(audit_id: params[:id])
    if @audit_detail.present?
      @scope = @audit_detail.scope
      @objectives = @audit_detail.objectives
      @purpose = @audit_detail.purpose
      @boundaries = @audit_detail.boundaries
    end

    @lead_auditor_id = @audit.audit_assignments.find_by(role: "lead_auditor")&.user_id
    @auditee_id = @audit.audit_assignments.find_by(role: "auditee")&.user_id
    @support_auditor_ids = @audit.audit_assignments.where(role: "auditor").pluck(:user_id)
    @sme_ids = @audit.audit_assignments.where(role: "sme").pluck(:user_id)
    @applicable_standards = @audit.audit_detail&.audit_standards&.pluck(:standard) || []

    # Load lists for dropdowns
    @final_outcomes = ["pass", "fail", "nil"]
    @statuses = ["not_started", "in_progress", "pending_review", "completed", "cancelled"]
    @companies = Company.all
    @auditees = User.auditee
    @audit_types = ["internal", "external"]
    @auditors = User.auditor
    @users = User.all
    @standards = AuditStandard.all
    @audit_details = AuditDetail.all
  end


  def update
    if params[:commit] == "Close Audit"
      redirect_to audits_path, notice: "No changes were saved. Audit not modified."
      return
    end

    @audit = Audit.find(params[:id])
    @company_id = @audit.company_id
    @audit_type = @audit.audit_type
    @scheduled_start = @audit.scheduled_start_date
    @scheduled_end = @audit.scheduled_end_date
    @actual_start = @audit.actual_start_date
    @actual_end = @audit.actual_end_date
    
    @audit_detail = AuditDetail.find_by(audit_id: params[:id])
    if @audit_detail.present?
      @scope = @audit_detail.scope
      @objectives = @audit_detail.objectives
      @purpose = @audit_detail.purpose
      @boundaries = @audit_detail.boundaries
    end

    @lead_auditor_id = @audit.audit_assignments.find_by(role: "lead_auditor")&.user_id
    @auditee_id = @audit.audit_assignments.find_by(role: "auditee")&.user_id
    @support_auditor_ids = @audit.audit_assignments.where(role: "auditor").pluck(:user_id)
    @sme_ids = @audit.audit_assignments.where(role: "sme").pluck(:user_id)
    @applicable_standards = @audit.audit_detail&.audit_standards&.pluck(:standard) || []

    # Load lists for dropdowns
    @final_outcomes = ["pass", "fail", "nil"]
    @statuses = ["not_started", "in_progress", "pending_review", "completed", "cancelled"]
    @companies = Company.all
    @auditees = User.auditee
    @audit_types = ["internal", "external"]
    @auditors = User.auditor
    @users = User.all
    @standards = AuditStandard.all
    @audit_details = AuditDetail.all

    required_fields = [
      params.dig(:company, :id),
      params.dig(:audit_assignment, :auditee),
      params.dig(:audit_assignment, :lead_auditor),
      params.dig(:audit, :scheduled_start_date),
      params.dig(:audit, :scheduled_end_date),
      params.dig(:audit, :audit_type),
      params.dig(:audit_detail, :scope),
      params.dig(:audit_detail, :objectives),
      params.dig(:audit_detail, :purpose),
      params.dig(:audit_detail, :boundaries)
    ]
    unless required_fields.all?(&:present?)
      flash.now[:alert] = "Invalid request changes of audit details. Please complete all required fields."
      
      # Refill variables used by the form
      @audit = Audit.find(params[:id])
      @company_id = params.dig(:company, :id)
      @audit_type = params.dig(:audit, :audit_type)
      @scheduled_start = params.dig(:audit, :scheduled_start_date)
      @scheduled_end = params.dig(:audit, :scheduled_end_date)
      @actual_start = params.dig(:audit, :actual_start_date)
      @actual_end = params.dig(:audit, :actual_end_date)

      @scope = params.dig(:audit_detail, :scope)
      @objectives = params.dig(:audit_detail, :objectives)
      @purpose = params.dig(:audit_detail, :purpose)
      @boundaries = params.dig(:audit_detail, :boundaries)

      @lead_auditor_id = params.dig(:audit_assignment, :lead_auditor)
      @auditee_id = params.dig(:audit_assignment, :auditee)
      @support_auditor_ids = params[:audit_assignment][:support_auditor].reject(&:blank?) rescue []
      @sme_ids = params[:audit_assignment][:sme].reject(&:blank?) rescue []
      @applicable_standards = params[:audit_standard][:standard].reject(&:blank?) rescue []

      # Reload dropdown data
      @final_outcomes = ["pass", "fail", "nil"]
      @statuses = ["not_started", "in_progress", "pending_review", "completed", "cancelled"]
      @companies = Company.all
      @auditees = User.auditee
      @audit_types = ["internal", "external"]
      @auditors = User.auditor
      @users = User.all
      @standards = AuditStandard.all
      @audit_details = AuditDetail.all

      render :edit
      return
    end
    
    @audit = Audit.find(params[:id])
    @audit.assign_attributes(
      company_id: params[:company][:id],
      audit_type: params[:audit][:audit_type],
      scheduled_start_date: params[:audit][:scheduled_start_date],
      scheduled_end_date: params[:audit][:scheduled_end_date],
      actual_start_date: params[:audit][:actual_start_date],
      actual_end_date: params[:audit][:actual_end_date]
    )

    if @audit.save
      # === Update AuditDetail ===
      audit_detail = @audit.audit_detail || @audit.build_audit_detail
      audit_detail.update(
        scope: params.dig(:audit_detail, :scope),
        objectives: params.dig(:audit_detail, :objectives),
        purpose: params.dig(:audit_detail, :purpose),
        boundaries: params.dig(:audit_detail, :boundaries)
      )

      # === Update AuditStandards ===
      audit_detail.audit_standards.destroy_all
      standards = params[:audit_standard][:standard] rescue []
      standards.each do |std|
        audit_detail.audit_standards.create(standard: std)
      end

      # === Update AuditAssignments ===
      @audit.audit_assignments.destroy_all

      @audit.audit_assignments.create(user_id: params[:audit_assignment][:lead_auditor], role: :lead_auditor, status: :assigned)
      @audit.audit_assignments.create(user_id: params[:audit_assignment][:auditee], role: :auditee, status: :assigned)

      if params[:audit_assignment][:support_auditor].present?
        params[:audit_assignment][:support_auditor].reject(&:blank?).each do |id|
          @audit.audit_assignments.create(user_id: id, role: :auditor, status: :assigned)
        end
      end      

      if params[:audit_assignment][:sme].present?
        params[:audit_assignment][:sme].reject(&:blank?).each do |id|
          @audit.audit_assignments.create(user_id: id, role: :sme, status: :assigned)
        end
      end      

      redirect_to edit_create_edit_audit_path(@audit), notice: "Audit updated successfully."
    else
      flash.now[:alert] = "Something went wrong while updating."
      render :edit
    end

  end


end
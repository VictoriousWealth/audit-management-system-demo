class CreateEditAuditsController < ApplicationController

  # GET /create_edit_audits/new
  def new
    prepare_options # Load dropdown options and other shared variables for the form
  end

  # POST /create_edit_audits
  def create
    # Handle "Close Audit" action - redirect without saving anything
    if params[:commit] == "Close Audit"
      redirect_to create_edit_audits_path, notice: "Audit creation cancelled. No data was saved."
      return
    end

    prepare_options # Load form data for re-rendering if needed

    # Extract nested params or default to empty hash if missing
    assignment = params[:audit_assignment] || {}
    audit = params[:audit] || {}
    audit_detail = params[:audit_detail] || {}
    company = params[:company] || {}

    # Required fields validation
    required_fields = [
      company[:id],
      assignment[:auditee],
      assignment[:lead_auditor],
      audit[:scheduled_start_date],
      audit[:scheduled_end_date],
      audit[:audit_type],
      audit_detail[:scope],
      audit_detail[:objectives],
      audit_detail[:purpose],
      audit_detail[:boundaries]
    ]

    # Check for any missing fields
    missing_fields = required_fields.select { |field| field.blank? }
    if missing_fields.any?
      flash.now[:alert] = "Please fill in the following required fields: #{missing_fields.join(', ')}"
      render :new
      return
    end

    # === Create Audit ===
    @audit = Audit.new(
      company_id: company[:id],
      audit_type: audit[:audit_type],
      scheduled_start_date: audit[:scheduled_start_date],
      scheduled_end_date: audit[:scheduled_end_date],
      actual_start_date: nil,
      actual_end_date: nil,
      status: :not_started,
      time_of_creation: Time.now(),
    )

    unless @audit.save
      flash.now[:alert] = "Something went wrong with saving this audit. Try again later."
      render :new
      return
    end

    # === Create AuditDetail ===
    audit_detail = AuditDetail.new(
      boundaries: audit_detail[:boundaries],
      objectives: audit_detail[:objectives],
      purpose: audit_detail[:purpose],
      scope: audit_detail[:scope],
      audit_id: @audit.id
    )

    unless audit_detail.save
      @audit.destroy # Rollback audit if detail fails
      flash.now[:alert] = "Something went wrong with saving this audit's details. Try again later."
      render :new
      return
    end

    # === Create AuditStandards ===
    audit_standard = params[:audit_standard] || {}
    standards = audit_standard[:standard] rescue []
    standards.each do |std|
      AuditStandard.create(
        standard: std,
        audit_detail_id: audit_detail.id
      )
      audit_detail.audit_standards.reload
      # NOTE: No user feedback on success/failure for each standard
    end

    # === Create AuditAssignments ===

    # Lead Auditor (required)
    if (lead_id = assignment[:lead_auditor]).present?
      @audit.audit_assignments.create(user_id: lead_id, role: :lead_auditor, status: :assigned, assigned_by: current_user.id)
    else
      @audit.destroy
      flash.now[:alert] = "Something went wrong with saving this audit's assignments. Try again later."
      render :new
      return
    end

    # Support Auditors (optional)
    if assignment[:support_auditor].present?
      assignment[:support_auditor].reject(&:blank?).each do |id|
        @audit.audit_assignments.create(user_id: id, role: :auditor, status: :assigned, assigned_by: current_user.id)
      end
    end

    # SMEs (optional)
    if assignment[:sme].present?
      assignment[:sme].reject(&:blank?).each do |id|
        @audit.audit_assignments.create(user_id: id, role: :sme, status: :assigned, assigned_by: current_user.id)
      end
    end

    # Auditee (required)
    if (auditee_id = assignment[:auditee]).present?
      @audit.audit_assignments.create(user_id: auditee_id, role: :auditee, status: :assigned, assigned_by: current_user.id)
    else
      @audit.destroy
      flash.now[:alert] = "Something went wrong with saving this audit's assignments. Try again later."
      render :new
      return
    end

    # === Notify assigned auditors and SMEs ===
    @audit.audit_assignments.each do |assignment|
      user = assignment.user
      AuditMailer.notify_assignment(assignment).deliver_later
    end

    redirect_to edit_create_edit_audit_path(@audit), notice: 'Audit created successfully.'
  end

  # GET /create_edit_audits/:id/edit
  def edit
    @audit = Audit.find(params[:id])

    # Pre-fill form fields
    @company_id = @audit.company_id
    @audit_type = @audit.audit_type
    @scheduled_start = @audit.scheduled_start_date
    @scheduled_end = @audit.scheduled_end_date
    @actual_start = @audit.actual_start_date
    @actual_end = @audit.actual_end_date

    @audit_detail = AuditDetail.find_by(audit_id: params[:id])
    @scope = @audit_detail.scope || nil
    @objectives = @audit_detail.objectives || nil
    @purpose = @audit_detail.purpose || nil
    @boundaries = @audit_detail.boundaries || nil

    # Pre-fill assignments
    @lead_auditor_id = @audit.audit_assignments.find_by(role: "lead_auditor")&.user_id
    @auditee_id = @audit.audit_assignments.find_by(role: "auditee")&.user_id
    @support_auditor_ids = @audit.audit_assignments.where(role: "auditor").pluck(:user_id)
    @sme_ids = @audit.audit_assignments.where(role: "sme").pluck(:user_id)
    @applicable_standards = @audit.audit_detail&.audit_standards&.pluck(:standard) || []

    prepare_options()
  end

  # PATCH/PUT /create_edit_audits/:id
  def update
    # Handle "Close Audit" without saving changes
    if params[:commit] == "Close Audit"
      redirect_to create_edit_audits_path, notice: "No changes were saved. Audit not modified."
      return
    end

    # Extract parameters
    assignment = params[:audit_assignment] || {}
    audit = params[:audit] || {}
    audit_detail = params[:audit_detail] || {}
    company = params[:company] || {}

    # Validate required fields
    required_fields = [
      company[:id],
      assignment[:auditee],
      assignment[:lead_auditor],
      audit[:scheduled_start_date],
      audit[:scheduled_end_date],
      audit[:audit_type],
      audit_detail[:scope],
      audit_detail[:objectives],
      audit_detail[:purpose],
      audit_detail[:boundaries]
    ]

    missing_fields = required_fields.select { |field| field.blank? }
    if missing_fields.any?
      flash.now[:alert] = "Please fill in the following required fields: #{missing_fields.join(', ')}"

      # Repopulate form variables
      @audit = Audit.find(params[:id])
      @company_id = company[:id]
      @audit_type = audit[:audit_type]
      @scheduled_start = audit[:scheduled_start_date]
      @scheduled_end = audit[:scheduled_end_date]
      @actual_start = audit[:actual_start_date]
      @actual_end = audit[:actual_end_date]

      @scope = audit_detail[:scope]
      @objectives = audit_detail[:objectives]
      @purpose = audit_detail[:purpose]
      @boundaries = audit_detail[:boundaries]

      @lead_auditor_id = assignment[:lead_auditor]
      @auditee_id = assignment[:auditee]
      @support_auditor_ids = assignment[:support_auditor].reject(&:blank?) rescue []
      @sme_ids = assignment[:sme].reject(&:blank?) rescue []
      audit_standard = params[:audit_standard] || {}
      @applicable_standards = audit_standard[:standard].reject(&:blank?) rescue []

      prepare_options
      render :edit
      return
    end

    # === Update Audit ===
    @audit = Audit.find_by(id: params[:id])
    @audit.update(
      company_id: company[:id],
      audit_type: audit[:audit_type],
      scheduled_start_date: audit[:scheduled_start_date],
      scheduled_end_date: audit[:scheduled_end_date],
      actual_start_date: audit[:actual_start_date],
      actual_end_date: audit[:actual_end_date]
    )

    unless @audit.save
      flash.now[:alert] = "Something went wrong while updating this audit."
      render :edit
      return
    end

    # === Update AuditDetail ===
    @audit_detail = AuditDetail.find_by(audit_id: @audit.id)
    if @audit_detail.present?
      scope = audit_detail[:scope]
      objectives = audit_detail[:objectives]
      purpose = audit_detail[:purpose]
      boundaries = audit_detail[:boundaries]

      if scope.present? && objectives.present? && purpose.present? && boundaries.present?
        unless @audit_detail.update(scope: scope, objectives: objectives, purpose: purpose, boundaries: boundaries)
          flash.now[:alert] = "Something went wrong while updating this audit's details."
          render :edit
          return
        end
      else
        flash.now[:alert] = "Something went wrong while updating the audit's details with the provided."
        render :edit
        return
      end
    else
      flash.now[:alert] = "Hmmm weird... Something went wrong while updating this audit's details."
      prepare_options
      render :edit
      return
    end

    # === Update AuditStandards ===
    @audit_detail.audit_standards.destroy_all
    audit_standard = params[:audit_standard] || {}
    standards = audit_standard[:standard] rescue []
    standards.each do |std|
      AuditStandard.create(
        standard: std,
        audit_detail_id: @audit_detail.id
      )
      @audit_detail.audit_standards.reload
    end

    # === Update AuditAssignments ===
    @audit.audit_assignments.destroy_all
    @audit.audit_assignments.create(user_id: assignment[:lead_auditor], role: :lead_auditor, status: :assigned)
    @audit.audit_assignments.create(user_id: assignment[:auditee], role: :auditee, status: :assigned)

    if assignment[:support_auditor].present?
      assignment[:support_auditor].reject(&:blank?).each do |id|
        AuditAssignment.create(audit_id: @audit.id, user_id: id, role: :auditor, status: :assigned)
      end
    end

    if assignment[:sme].present?
      assignment[:sme].reject(&:blank?).each do |id|
        AuditAssignment.create(audit_id: @audit.id, user_id: id, role: :sme, status: :assigned)
      end
    end

    #------------------------------------------------------------------------------------------------
    # === Notify assigned auditors and SMEs about update ===
    @audit.audit_assignments.each do |assignment|
      user = assignment.user
      AuditMailer.notify_assignment(assignment).deliver_later
    end

    redirect_to edit_create_edit_audit_path(@audit.reload), notice: "Audit updated successfully."
  end

  private

  # Shared dropdown and data-loading logic
  def prepare_options
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

end

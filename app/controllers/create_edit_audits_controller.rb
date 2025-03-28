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
      redirect_to create_edit_audits_path, notice: "Audit creation cancelled. No data was saved."
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

    assignment = params[:audit_assignment] || {}
    audit = params[:audit] || {}
    audit_detail = params[:audit_detail] || {}
    required_fields = [
      params.dig(:company, :id),
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

    unless required_fields.all?(&:present?)
      flash.now[:alert] = "Please fill in all required fields before submitting."
      render :new
      return
    end
    
    # Proceed with saving logic below...
    # Find the company
    company_id = params.dig(:company, :id)
  
    # Create the Audit
    @audit = Audit.new(
      company_id: company_id,
      audit_type: params.dig(:audit, :audit_type),
      scheduled_start_date: params.dig(:audit, :scheduled_start_date),
      scheduled_end_date: params.dig(:audit, :scheduled_end_date),
      actual_start_date: params.dig(:audit, :actual_start_date),
      actual_end_date: params.dig(:audit, :actual_end_date)
    )
    puts @audit.errors.full_messages

    if @audit.save
      # Create AuditDetail
      audit_detail = AuditDetail.new(
        boundaries: params.dig(:audit_detail, :boundaries),
        objectives: params.dig(:audit_detail, :objectives),
        purpose: params.dig(:audit_detail, :purpose),
        scope: params.dig(:audit_detail, :scope),
        audit_id: @audit.id
      )

      # Check if save is successful or failed
      puts "Before creating detail: #{AuditDetail.count}"
      if audit_detail.save
        # Proceed if save is successful
        puts "AuditDetail created successfully!"
      else
        # Print out errors if save fails
        puts "Failed to create AuditDetail: #{audit_detail.errors.full_messages.join(', ')}"
        render :new and return # Early return if AuditDetail fails to save
      end
      puts "After creating detail: #{AuditDetail.count}"

  
      # Create AuditStandards
      puts "Before creating standards: #{AuditStandard.count}"
      standards = params[:audit_standard][:standard] rescue []
      standards.each do |std|
        AuditStandard.create(standard: std, audit_detail_id: audit_detail.id)
        puts "Created AuditStandard: #{std}"
        # Check if i`t's saved successfully
        audit_detail.audit_standards.reload
        puts "AuditStandard count after creation: #{audit_detail.audit_standards.count}"
      end
      puts "After creating standards: #{AuditStandard.count}"


  
      # Create AuditAssignments
      puts "Before creating lead auditor assignment: #{AuditAssignment.count}"
      if (lead_id = params.dig(:audit_assignment, :lead_auditor)).present?
        @audit.audit_assignments.create(user_id: lead_id, role: :lead_auditor, status: :assigned)
        puts "Lead auditor assignment successfully created"
      else 
        puts "Lead auditor assignment failed to create"
      end
      puts "After creating lead auditor assignment: #{AuditAssignment.count}"

      # For Support Auditor Assignment
      puts "Before creating support auditor assignments: #{AuditAssignment.count}"
      if params[:audit_assignment][:support_auditor].present?
        params[:audit_assignment][:support_auditor].reject(&:blank?).each do |id|
          assignment = @audit.audit_assignments.create(user_id: id, role: :auditor, status: :assigned)
          puts "Support auditor assignment #{assignment.id} successfully created"
        end
      else
        puts "Support auditor assignments failed to create"
      end
      puts "After creating support auditor assignments: #{AuditAssignment.count}"

      # For SME Assignment
      puts "Before creating sme assignments: #{AuditAssignment.count}"
      if params[:audit_assignment][:sme].present?
        params[:audit_assignment][:sme].reject(&:blank?).each do |id|
          assignment = @audit.audit_assignments.create(user_id: id, role: :sme, status: :assigned)
          puts "SME assignment #{assignment.id} successfully created"
        end
      else
        puts "SME assignments failed to create"
      end
      puts "After creating sme assignments: #{AuditAssignment.count}"


      
      puts "Before creating auditee assignment: #{AuditAssignment.count}"
      if (auditee_id = params.dig(:audit_assignment, :auditee)).present?
        @audit.audit_assignments.create(user_id: auditee_id, role: :auditee, status: :assigned)
        puts "Auditee assignment created successuflly."
      else
        puts "Auditee assignment failed to create."
      end
      puts "After creating auditee assignment: #{AuditAssignment.count}"

      puts "Audit created sucessfully"
      redirect_to edit_create_edit_audit_path(@audit), notice: 'Audit created successfully.'
    else
      puts "Failed to create Audit: #{@audit.errors.full_messages.join(', ')}"
      render :new and return
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
      redirect_to create_edit_audits_path, notice: "No changes were saved. Audit not modified."
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
      # Find the AuditDetail associated with the current Audit
      audit_detail = AuditDetail.find_by(audit_id: @audit.id)

      if audit_detail.present?
        scope = params.dig(:audit_detail, :scope)
        objectives = params.dig(:audit_detail, :objectives)
        purpose = params.dig(:audit_detail, :purpose)
        boundaries = params.dig(:audit_detail, :boundaries)

        if scope.present? && objectives.present? && purpose.present? && boundaries.present?
          if audit_detail.update(
                scope: scope,
                objectives: objectives,
                purpose: purpose,
                boundaries: boundaries
              )
            puts "AuditDetail updated successfully!"
          else
            puts "Failed to update AuditDetail: #{audit_detail.errors.full_messages.join(', ')}"
          end
        else
          puts "Missing required parameters for AuditDetail update."
        end
      else
        puts "AuditDetail not found for Audit ID: #{@audit.id}"
      end



      # === Update AuditStandards ===
      audit_detail.audit_standards.destroy_all
      standards = params[:audit_standard][:standard] rescue []
      standards.each do |std|
        AuditStandard.create(standard: std, audit_detail_id: audit_detail.id)
        puts "Created AuditStandard: #{std}"  # Log the created standard
        # Check if i`t's saved successfully
        audit_detail.audit_standards.reload
        puts "AuditStandard count after creation: #{audit_detail.audit_standards.count}"
      end

      # === Update AuditAssignments ===
      @audit.audit_assignments.destroy_all

      @audit.audit_assignments.create(user_id: params[:audit_assignment][:lead_auditor], role: :lead_auditor, status: :assigned)
      @audit.audit_assignments.create(user_id: params[:audit_assignment][:auditee], role: :auditee, status: :assigned)

      if params[:audit_assignment][:support_auditor].present?
        params[:audit_assignment][:support_auditor].reject(&:blank?).each do |id|
          AuditAssignment.create(audit_id: @audit.id, user_id: id, role: :auditor, status: :assigned)
        end
        puts "Support auditor assignments created successfully."
      else 
        puts "Failed to create support_auditor assignments."
      end      

      if params[:audit_assignment][:sme].present?
        params[:audit_assignment][:sme].reject(&:blank?).each do |id|
          AuditAssignment.create(audit_id: @audit.id, user_id: id, role: :sme, status: :assigned)
        end
        puts "Sme assignments created successfully."
      else 
        puts "Failed to create sme assignments."
      end      

      redirect_to edit_create_edit_audit_path(@audit.reload), notice: "Audit updated successfully."
    else
      puts "Failed to create audit."
      flash.now[:alert] = "Something went wrong while updating."
      render :edit
    end

  end


end
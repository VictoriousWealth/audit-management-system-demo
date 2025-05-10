class SmeDashboardController < ApplicationController
  before_action :authenticate_user!

  def sme
    scheduled_audits()
    in_progress_audits()
    completed_audits()

    calendar_events()
    audit_findings()
    corrective_actions()
    documents()
  end

  private
  def documents
    @documents = SupportingDocument
      .joins(audit: :audit_assignments)
      .where(audit_assignments: {
        user_id: current_user.id,
        role: AuditAssignment.roles[:sme],
      })
      .distinct
      .map do |d|
        {
          id: d.id,
          title: d.name,
          content: d.content,
          file: d.file
        }
      end
  end

  def corrective_actions
    @corrective_actions = []
  
    CorrectiveAction.includes(audit: { audit_assignments: :user }).find_each do |c|
      audit = c.audit
      next unless audit
  
      # Only include if current_user is sme
      relevant = audit.audit_assignments.any? do |assignment|
        assignment.user_id == current_user.id && %w[sme].include?(assignment.role)
      end
      next unless relevant
  
      # Determine progress based on status enum
      progress = case c.status.to_sym
                 when :pending then 33  
                 when :in_progress then 66  
                 else 100        
                 end
  
      short_description = c.action_description.length > 15 ? "#{c.action_description[0...12]}..." : c.action_description
  
      # Get auditee's company name
      auditee_assignment = audit.audit_assignments.find { |a| a.role == "auditee" }
      company_name = auditee_assignment&.user&.company&.name
  
      @corrective_actions << {
        id: c.id,
        truncated_description: short_description,
        full_description: c.action_description,
        vendor: company_name,
        progress: progress
      }
    end
  end
  

  def audit_findings
    @audit_findings = []
  
    AuditFinding.includes(report: { audit: :audit_assignments }).find_each do |finding|
      audit = finding.report&.audit
      next unless audit
  
      # Only include if current_user is assigned as sme
      relevant = audit.audit_assignments.any? do |assignment|
        assignment.user_id == current_user.id && %w[sme].include?(assignment.role)
      end
      next unless relevant
  
      category = case finding.category.to_sym
                 when :critical then "critical"
                 when :major then "major"
                 else "minor"
                 end
  
      short_description = finding.description.length > 15 ? "#{finding.description[0...12]}..." : finding.description
  
      @audit_findings << {
        id: finding.id,
        audit_type: audit.audit_type,
        truncated_description: short_description,
        full_description: finding.description,
        category: category
      }
    end
  end
  


  def calendar_events
    # === Calendar Event Component ===
    today = Time.zone.today
    @calendar_events = []
  
    # === Base: Only audits relevant to the current user ===
    user_audits = Audit
      .includes(:audit_assignments)
      .select do |audit|
        audit.audit_assignments.any? do |assignment|
          assignment.user_id == current_user.id && %w[sme].include?(assignment.role)
        end
      end
  
    # === Category 1: Scheduled to End Per Date ===
    user_audits.select { |a| a.scheduled_end_date.present? }
               .group_by { |a| a.scheduled_end_date.to_date }
               .each do |date, audits|
      @calendar_events << {
        title: "🔵#{audits.size}",
        date: date,
        allDay: true,
        textColor: "#000",
        description: "#{audits.size} audit(s) scheduled to end on #{date}"
      }
    end
  
    # === Category 2: In Progress (Late) ===
    overdue_audits = user_audits.select do |a|
      a.status != "completed" && a.scheduled_end_date.present? && a.scheduled_end_date.to_date < today
    end
  
    if overdue_audits.any?
      @calendar_events << {
        title: "🔴#{overdue_audits.count}",
        date: today,
        allDay: true,
        textColor: "#000",
        description: "#{overdue_audits.count} audit(s) overdue as of today"
      }
    end
  
    # === Category 3: In Progress (On Time) ===
    on_time_audits = user_audits.select do |a|
      a.status == "in_progress" && (a.scheduled_end_date.blank? || a.scheduled_end_date.to_date >= today)
    end
  
    if on_time_audits.any?
      @calendar_events << {
        title: "🟡#{on_time_audits.count}",
        date: today,
        allDay: true,
        textColor: "#000",
        description: "#{on_time_audits.count} audit(s) in progress (on time)"
      }
    end
  end
  
  def scheduled_audits
    @scheduled_audits = Audit
      .where(status: :not_started)
      .includes(audit_assignments: :user, audit_detail: :audit_standards)
      .select { |audit|
        audit.audit_assignments.any? do |assignment|
          assignment.user_id == current_user.id && %w[sme].include?(assignment.role)
        end
      }
      .map do |audit|
        lead_auditor = audit.audit_assignments.find { |a| a.role == "lead_auditor" }&.user
        auditee = audit.audit_assignments.find { |a| a.role == "auditee" }&.user
  
        {
          id: audit.id,
          scope: audit.audit_detail&.scope,
          location: [audit.company&.street_name, audit.company&.postcode, audit.company&.city].compact.join(", "),
          company_name: audit.company&.name,
          auditee: auditee&.full_name,
          lead_auditor: lead_auditor&.full_name,
          support_auditors: audit.auditors,
          smes: audit.smes,
          scheduled_start_date: audit.scheduled_start_date,
          scheduled_end_date: audit.scheduled_end_date,
          rpn: audit.company&.vendor_rpns&.order(created_at: :desc)&.first&.calculate_rpn
        }
      end
  end
  
  def in_progress_audits
    @in_progress_audits = Audit
      .where(status: :in_progress)
      .includes(audit_assignments: :user, audit_detail: :audit_standards)
      .select { |audit|
        audit.audit_assignments.any? do |assignment|
          assignment.user_id == current_user.id && %w[sme].include?(assignment.role)
        end
      }
      .map do |audit|
        lead_auditor = audit.audit_assignments.find { |a| a.role == "lead_auditor" }&.user
        auditee = audit.audit_assignments.find { |a| a.role == "auditee" }&.user
  
        {
          id: audit.id,
          company_name: audit.company&.name,
          scope: audit.audit_detail&.scope,
          location: [audit.company&.street_name, audit.company&.postcode, audit.company&.city].compact.join(", "),
          auditee: auditee&.full_name,
          lead_auditor: lead_auditor&.full_name,
          support_auditors: audit.auditors,
          smes: audit.smes,
          scheduled_start_date: audit.scheduled_start_date,
          scheduled_end_date: audit.scheduled_end_date,
          actual_start_date: audit.actual_start_date,
          progress: audit.score,
          rpn: audit.company&.vendor_rpns&.order(created_at: :desc)&.first&.calculate_rpn
        }
      end
  end

  def completed_audits
    @completed_audits = Audit
      .where(status: :completed)
      .includes(audit_assignments: :user, audit_detail: :audit_standards)
      .select { |audit|
        audit.audit_assignments.any? do |assignment|
          assignment.user_id == current_user.id && %w[sme].include?(assignment.role)
        end
      }
      .map do |audit|
        lead_auditor = audit.audit_assignments.find { |a| a.role == "lead_auditor" }&.user
        auditee = audit.audit_assignments.find { |a| a.role == "auditee" }&.user
  
        {
          id: audit.id,
          company_name: audit.company&.name,
          auditee: auditee&.full_name,
          lead_auditor: lead_auditor&.full_name,
          score: audit.score,
          final_outcome: audit.final_outcome,
          scheduled_start_date: audit.scheduled_start_date,
          scheduled_end_date: audit.scheduled_end_date,
          actual_start_date: audit.actual_start_date,
          actual_end_date: audit.actual_end_date,
          rpn: audit.company&.vendor_rpns&.order(created_at: :desc)&.first&.calculate_rpn,
          risk_level: risk_level(audit)
        }
      end
  end  

  def risk_level(audit)
    categories = AuditFinding.categories.keys # ["major", "minor", "critical"]
    category_counts = AuditFinding.where(report_id: Report.where(audit_id: audit.id).pluck(:id)) # there are multiple reports per one audit, idk why :(
                                  .group(:category)
                                  .count

    category_counts = categories.each_with_object({}) do |category, hash|
      hash[category] = category_counts[category] || 0
    end

    if category_counts["critical"] >= 1
      "High Risk"
    elsif category_counts["major"] >= 5
      "High Risk"
    elsif category_counts["minor"] >= 5
      "Medium Risk"
    elsif category_counts["major"] >= 1
      "Medium Risk"
    else
      "Low Risk"
    end    
  end
end


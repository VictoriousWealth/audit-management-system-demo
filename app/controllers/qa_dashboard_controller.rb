class QaDashboardController < ApplicationController
  before_action :authenticate_user!

  def qa_manager
    scheduled_audits()
    in_progress_audits()
    completed_audits()

    pie_chart_data()
    bar_chart_data()
    compliance_score_graph_over_time()

    calendar_events()
    audit_findings()
    corrective_actions()
    documents()
    internal_vs_external()
  end

  private
  def internal_vs_external
    internal_avg = Audit.internal.average(:score)&.round(2) || 0
    external_avg = Audit.external.average(:score)&.round(2) || 0
  
    @internal_vs_external = {
      internal_average: internal_avg,
      external_average: external_avg
    }
  end

  def documents
    @documents = SupportingDocument
      .joins(audit: :audit_assignments)
      .where(audit_assignments: {
        assigned_by: current_user.id
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
    audit_ids = AuditAssignment.where(assigned_by: current_user.id).pluck(:audit_id).uniq
  
    @corrective_actions = CorrectiveAction
      .includes(audit: { audit_assignments: :user })
      .where(audit_id: audit_ids)
      .map do |c|
        progress = case c.status
                   when 0 then 33
                   when 1 then 66
                   else 100
                   end
  
        short_description = c.action_description.length > 15 ? "#{c.action_description[0...12]}..." : c.action_description
  
        auditee_assignment = c.audit.audit_assignments.find { |a| a.role == 'auditee' }
        company_name = auditee_assignment&.user&.company&.name
  
        {
          id: c.id,
          truncated_description: short_description,
          full_description: c.action_description,
          vendor: company_name,
          progress: progress
        }
      end
  end

  def audit_findings
    # Only audits where current_user is the assigner
    assigned_audit_ids = AuditAssignment.where(assigned_by: current_user.id).pluck(:audit_id).uniq
  
    # Get reports for those audits
    report_ids = Report.where(audit_id: assigned_audit_ids).pluck(:id)
  
    # Preload everything to avoid N+1
    @audit_findings = AuditFinding
      .includes(report: :audit)
      .where(report_id: report_ids)
      .map do |f|
        category = case f.category.to_sym
                   when :critical then "critical"
                   when :major then "major"
                   else "minor"
                   end
  
        short_description = f.description.length > 15 ? "#{f.description[0...12]}..." : f.description
  
        {
          id: f.id,
          audit_type: f.report&.audit&.audit_type,
          truncated_description: short_description,
          full_description: f.description,
          category: category
        }
      end 
  end

  def calendar_events
    today = Time.zone.today
    @calendar_events = []
  
    # Get audits assigned by current_user
    assigned_audit_ids = AuditAssignment.where(assigned_by: current_user.id).pluck(:audit_id).uniq
    audits = Audit.where(id: assigned_audit_ids)
  
    # === Category 1: Scheduled to End Per Date ===
    audits.where.not(scheduled_end_date: nil)
          .group("DATE(scheduled_end_date)").count
          .each do |date, count|
      @calendar_events << {
        title: "🔵#{count}",
        date: date,
        allDay: true,
        textColor: "#000",
        description: "#{count} audit(s) scheduled to end on #{date}"
      }
    end
  
    # === Category 2: Overdue Audits ===
    overdue_count = audits.where.not(status: Audit.statuses[:completed])
                          .where.not(scheduled_end_date: nil)
                          .where("DATE(scheduled_end_date) < ?", today)
                          .count
  
    if overdue_count > 0
      @calendar_events << {
        title: "🔴#{overdue_count}",
        date: today,
        allDay: true,
        textColor: "#000",
        description: "#{overdue_count} audit(s) overdue as of today"
      }
    end
  
    # === Category 3: In-progress (on time) ===
    in_progress_count = audits.where(status: Audit.statuses[:in_progress])
                              .where("scheduled_end_date IS NULL OR DATE(scheduled_end_date) >= ?", today)
                              .count
  
    if in_progress_count > 0
      @calendar_events << {
        title: "🟡#{in_progress_count}",
        date: today,
        allDay: true,
        textColor: "#000",
        description: "#{in_progress_count} audit(s) in progress"
      }
    end
  end

  def compliance_score_graph_over_time
    compliance_score_graph_over_time_all()
    compliance_score_graph_over_time_day()
    compliance_score_graph_over_time_week()
    compliance_score_graph_over_time_month()
  end

  def compliance_score_graph_over_time_day
    today_range = Time.zone.today.beginning_of_day..Time.zone.today.end_of_day
  
    assigned_audit_ids = AuditAssignment.where(assigned_by: current_user.id).pluck(:audit_id).uniq
  
    base_scope = Audit.where(id: assigned_audit_ids)
                      .where.not(score: nil)
                      .where.not(actual_end_date: nil)
                      .where(actual_end_date: today_range)
  
    @compliance_score_by_day = [
      {
        name: "Internal",
        color: "#42CA68",
        data: base_scope.where(audit_type: "internal")
                        .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "External",
        color: "#F39C12",
        data: base_scope.where(audit_type: "external")
                        .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "All Audits",
        color: "#3498DB",
        data: base_scope.map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      }
    ]
  end
  
  def compliance_score_graph_over_time_week
    week_range = Time.zone.now.beginning_of_week..Time.zone.now.end_of_week
  
    # Get only audit IDs assigned by current_user
    assigned_audit_ids = AuditAssignment.where(assigned_by: current_user.id).pluck(:audit_id).uniq
  
    # Base scope: audits in that week, assigned by current user, and with score and actual_end_date
    base_scope = Audit.where(id: assigned_audit_ids)
                      .where.not(score: nil)
                      .where.not(actual_end_date: nil)
                      .where(actual_end_date: week_range)
  
    @compliance_score_by_week = [
      {
        name: "Internal",
        color: "#42CA68",
        data: base_scope.where(audit_type: "internal")
                        .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "External",
        color: "#F39C12",
        data: base_scope.where(audit_type: "external")
                        .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "All Audits",
        color: "#3498DB",
        data: base_scope.map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      }
    ]
  end
  
  def compliance_score_graph_over_time_month
    month_range = Time.zone.now.beginning_of_month..Time.zone.now.end_of_month
  
    assigned_audit_ids = AuditAssignment.where(assigned_by: current_user.id).pluck(:audit_id).uniq
  
    base_scope = Audit.where(id: assigned_audit_ids)
                      .where.not(score: nil)
                      .where.not(actual_end_date: nil)
                      .where(actual_end_date: month_range)
  
    @compliance_score_by_month = [
      {
        name: "Internal",
        color: "#42CA68",
        data: base_scope.where(audit_type: "internal")
                        .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "External",
        color: "#F39C12",
        data: base_scope.where(audit_type: "external")
                        .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "All Audits",
        color: "#3498DB",
        data: base_scope.map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      }
    ]
  end

  def compliance_score_graph_over_time_all
    assigned_audit_ids = AuditAssignment.where(assigned_by: current_user.id).pluck(:audit_id).uniq
  
    base_scope = Audit.where(id: assigned_audit_ids)
                      .where.not(score: nil)
                      .where.not(actual_end_date: nil)
                      .order(:actual_end_date)
  
    @compliance_score_all = [
      {
        name: "Internal",
        color: "#42CA68",
        data: base_scope.where(audit_type: "internal")
                        .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "External",
        color: "#F39C12",
        data: base_scope.where(audit_type: "external")
                        .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "All Audits",
        color: "#3498DB",
        data: base_scope.map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      }
    ]
  end
  
  def bar_chart_data
    # Get audit IDs assigned by current user
    assigned_audit_ids = AuditAssignment.where(assigned_by: current_user.id).pluck(:audit_id).uniq
  
    # Base scoped audits
    scoped_audits = Audit.where(id: assigned_audit_ids)
  
    # Build chart data
    @bar_chart_data = [
      {
        name: "Completed",
        data: [["Audits", scoped_audits.where(status: :completed).count]]
      },
      {
        name: "In Progress (on time)",
        data: [["Audits", scoped_audits.where(status: :in_progress)
                                       .where("actual_start_date <= scheduled_start_date").count]]
      },
      {
        name: "In Progress (late)",
        data: [["Audits", scoped_audits.where(status: :in_progress)
                                       .where("actual_start_date > scheduled_start_date").count]]
      },
      {
        name: "Not Started",
        data: [["Audits", scoped_audits.where(status: :not_started).count]]
      }
    ]
  
    # Calculate suggested Y-axis max
    max_value = @bar_chart_data.map { |s| s[:data][0][1] }.max
    suggested_max = (max_value * 1.1).ceil
  
    # Chart configuration
    @bar_chart_library = {
      title: { text: "Audit Status Overview", display: true },
      scales: {
        y: {
          suggestedMax: suggested_max
        }
      },
      plugins: {
        legend: {
          display: true,
          position: 'top',
          fullSize: false,
          labels: {
            padding: 20,
            usePointStyle: true,
            pointStyle: 'circle',
            color: "#000",
            font: { weight: 'bold', size: 12 }
          }
        },
        datalabels: {
          anchor: 'end',
          align: 'top',
          color: '#000',
          font: { weight: 'bold' }
        }
      }
    }
  end
  
  def pie_chart_data
    # Only audits where the current user assigned someone
    assigned_audit_ids = AuditAssignment.where(assigned_by: current_user.id).pluck(:audit_id).uniq
  
    audits = Audit.where(id: assigned_audit_ids)
  
    @pie_chart_data = {
      "Completed": audits.where(status: :completed).count,
  
      "In Progress (on time)": audits.where(status: :in_progress)
                                     .where('actual_start_date <= scheduled_start_date')
                                     .count,
  
      "In Progress (late)": audits.where(status: :in_progress)
                                  .where('actual_start_date > scheduled_start_date')
                                  .count,
  
      "Not Started": audits.where(status: :not_started).count
    }
  end

  def scheduled_audits
    assigned_audit_ids = AuditAssignment.where(assigned_by: current_user.id).pluck(:audit_id).uniq
  
    @scheduled_audits = Audit.where(id: assigned_audit_ids, status: :not_started)
                              .includes(audit_assignments: :user, audit_detail: :audit_standards)
                              .map do |audit|
      lead_auditor = audit.audit_assignments.find { |a| a.role == 'lead_auditor' }&.user
      auditee = audit.audit_assignments.find { |a| a.role == 'auditee' }&.user
  
      {
        id: audit.id,
        audit_type: audit.audit_type,
        company_name: audit.company&.name,
        auditee: auditee&.full_name,
        lead_auditor: lead_auditor&.full_name,
        support_auditors: audit.auditors(),
        smes: audit.smes(),
        scheduled_start_date: audit.scheduled_start_date,
        scheduled_end_date: audit.scheduled_end_date,
        rpn: VendorRpn.where(company_id: audit.company_id).order(created_at: :desc).first&.calculate_rpn
      }
    end
  end
  
  def in_progress_audits
    assigned_audit_ids = AuditAssignment.where(assigned_by: current_user.id).pluck(:audit_id).uniq
  
    @in_progress_audits = Audit.where(id: assigned_audit_ids, status: :in_progress)
                                .includes(audit_assignments: :user)
                                .map do |audit|
      lead_auditor = audit.audit_assignments.find { |a| a.role == 'lead_auditor' }&.user
      auditee = audit.audit_assignments.find { |a| a.role == 'auditee' }&.user
  
      {
        id: audit.id,
        audit_type: audit.audit_type,
        company_name: audit.company&.name,
        auditee: auditee&.full_name,
        lead_auditor: lead_auditor&.full_name,
        support_auditors: audit.auditors(),
        smes: audit.smes(),
        scheduled_start_date: audit.scheduled_start_date,
        scheduled_end_date: audit.scheduled_end_date,
        actual_start_date: audit.actual_start_date,
        progress: audit.score,
        rpn: VendorRpn.where(company_id: audit.company_id).order(created_at: :desc).first&.calculate_rpn
      }
    end
  end

  def completed_audits
    assigned_audit_ids = AuditAssignment.where(assigned_by: current_user.id).pluck(:audit_id).uniq
  
    @completed_audits = Audit.where(id: assigned_audit_ids, status: :completed)
                              .includes(audit_assignments: :user, audit_detail: :audit_standards)
                              .map do |audit|
      lead_auditor = audit.audit_assignments.find { |a| a.role == 'lead_auditor' }&.user
      auditee = audit.audit_assignments.find { |a| a.role == 'auditee' }&.user
  
      {
        id: audit.id,
        audit_type: audit.audit_type,
        company_name: audit.company&.name,
        auditee: auditee&.full_name,
        lead_auditor: lead_auditor&.full_name,
        score: audit.score,
        final_outcome: audit.final_outcome,
        scheduled_start_date: audit.scheduled_start_date,
        scheduled_end_date: audit.scheduled_end_date,
        actual_start_date: audit.actual_start_date,
        actual_end_date: audit.actual_end_date,
        rpn: VendorRpn.where(company_id: audit.company_id).order(created_at: :desc).first&.calculate_rpn,
        risk_level: risk_level(audit)
      }
    end
  end
  
  def risk_level(audit)
    categories = AuditFinding.categories.keys # ["major", "minor", "critical"]
  
    raw_counts = AuditFinding.where(report_id: Report.where(audit_id: audit.id).pluck(:id))
                             .group(:category)
                             .count
  
    # Normalize all expected categories to ensure zeroes are included
    category_counts = categories.each_with_object({}) do |category, hash|
      hash[category] = raw_counts[category] || 0
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


class AuditorDashboardController < ApplicationController
  before_action :authenticate_user!

  def auditor
    scheduled_audits()
    in_progress_audits()
    completed_audits()

    pie_chart_data()
    bar_chart_data()
    compliance_score_graph_over_time()

    calendar_events()
    audit_fidnings()
    corrective_actions()
    documents()
  end

  private
  def documents
    @documents = SupportingDocument
      .joins(audit: :audit_assignments)
      .where(audit_assignments: {
        user_id: current_user.id,
        role: [AuditAssignment.roles[:auditor], AuditAssignment.roles[:lead_auditor]]
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
  
      # Only include if current_user is lead/support/sme
      relevant = audit.audit_assignments.any? do |assignment|
        assignment.user_id == current_user.id && %w[lead_auditor auditor sme].include?(assignment.role)
      end
      next unless relevant
  
      # Determine progress based on status enum
      progress = case c.status
                 when 0 then 33  # pending
                 when 1 then 66  # in_progress
                 else 100        # completed
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
  

  def audit_fidnings
    @audit_fidnings = []
  
    AuditFinding.includes(report: { audit: :audit_assignments }).find_each do |finding|
      audit = finding.report&.audit
      next unless audit
  
      # Only include if current_user is assigned as lead/support/sme
      relevant = audit.audit_assignments.any? do |assignment|
        assignment.user_id == current_user.id && %w[lead_auditor auditor sme].include?(assignment.role)
      end
      next unless relevant
  
      category = case finding.category
                 when 0 then "critical"
                 when 1 then "major"
                 else "minor"
                 end
  
      short_description = finding.description.length > 15 ? "#{finding.description[0...12]}..." : finding.description
  
      @audit_fidnings << {
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
          assignment.user_id == current_user.id && %w[lead_auditor auditor sme].include?(assignment.role)
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
  
  def compliance_score_graph_over_time
    compliance_score_graph_over_time_all()
    compliance_score_graph_over_time_day()
    compliance_score_graph_over_time_week()
    compliance_score_graph_over_time_month()
  end

  def compliance_score_graph_over_time_day
    # Time range for today
    today_range = Time.zone.today.beginning_of_day..Time.zone.today.end_of_day
  
    # All completed + scored audits today
    all_daily_audits = Audit.where.not(score: nil)
                            .where.not(actual_end_date: nil)
                            .where(actual_end_date: today_range)
                            .includes(:audit_assignments)
                            .order(:actual_end_date)
  
    # Only audits where the current user is involved as lead/support/sme
    my_daily_audits = all_daily_audits.select do |audit|
      audit.audit_assignments.any? do |assignment|
        assignment.user_id == current_user.id && %w[lead_auditor auditor sme].include?(assignment.role)
      end
    end
  
    @compliance_score_by_day = [
      {
        name: "All Audits",
        color: "#3498DB",
        data: all_daily_audits.map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y %H:%M"), audit.score] }
      },
      {
        name: "My Audits",
        color: "#42CA68",
        data: my_daily_audits.map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y %H:%M"), audit.score] }
      }
    ]
  end
  

  def compliance_score_graph_over_time_week
    # Time range for the current week
    current_week_range = Time.zone.now.beginning_of_week..Time.zone.now.end_of_week
  
    # All completed + scored audits in the current week
    all_weekly_audits = Audit.where.not(score: nil)
                             .where.not(actual_end_date: nil)
                             .where(actual_end_date: current_week_range)
                             .includes(:audit_assignments)
                             .order(:actual_end_date)
  
    # Only audits where the current user is involved as lead/support/sme
    my_weekly_audits = all_weekly_audits.select do |audit|
      audit.audit_assignments.any? do |assignment|
        assignment.user_id == current_user.id && %w[lead_auditor auditor sme].include?(assignment.role)
      end
    end
  
    @compliance_score_by_week = [
      {
        name: "All Audits",
        color: "#3498DB",
        data: all_weekly_audits.map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y %H:%M"), audit.score] }
      },
      {
        name: "My Audits",
        color: "#42CA68",
        data: my_weekly_audits.map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y %H:%M"), audit.score] }
      }
    ]
  end
  

  def compliance_score_graph_over_time_month
    # Time range for the current month
    current_month_range = Time.zone.now.beginning_of_month..Time.zone.now.end_of_month
  
    # All completed + scored audits in the current month
    all_monthly_audits = Audit.where.not(score: nil)
                              .where.not(actual_end_date: nil)
                              .where(actual_end_date: current_month_range)
                              .includes(:audit_assignments)
                              .order(:actual_end_date)
  
    # Only audits where the current user is involved as lead/support/sme
    my_monthly_audits = all_monthly_audits.select do |audit|
      audit.audit_assignments.any? do |assignment|
        assignment.user_id == current_user.id && %w[lead_auditor auditor sme].include?(assignment.role)
      end
    end
  
    @compliance_score_by_month = [
      {
        name: "All Audits",
        color: "#3498DB",
        data: all_monthly_audits.map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y %H:%M"), audit.score] }
      },
      {
        name: "My Audits",
        color: "#42CA68",
        data: my_monthly_audits.map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y %H:%M"), audit.score] }
      }
    ]
  end
  

  def compliance_score_graph_over_time_all
    # Filter all scored + completed audits
    all_scored_audits = Audit.where.not(score: nil).where.not(actual_end_date: nil).order(:actual_end_date)
  
    # Filter scored + completed audits where current_user is involved as lead/support/sme
    my_scored_audits = all_scored_audits.select do |audit|
      audit.audit_assignments.any? do |assignment|
        assignment.user_id == current_user.id && %w[lead_auditor auditor sme].include?(assignment.role)
      end
    end
  
    @compliance_score_all = [
      {
        name: "All Audits",
        color: "#3498DB",
        data: all_scored_audits.map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y %H:%M"), audit.score] }
      },
      {
        name: "My Audits",
        color: "#42CA68",
        data: my_scored_audits.map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y %H:%M"), audit.score] }
      }
    ]
  end
  

  def bar_chart_data
    visible_audits = Audit
      .includes(:audit_assignments)
      .select { |audit|
        audit.audit_assignments.any? do |assignment|
          assignment.user_id == current_user.id && %w[lead_auditor auditor sme].include?(assignment.role)
        end
      }
  
    @bar_chart_data = [
      { name: "Completed", data: [["Audits", visible_audits.count { |a| a.status == "completed" }]] },
  
      { name: "In Progress (on time)", data: [["Audits", visible_audits.count { |a|
        a.status == "in_progress" && a.actual_start_date && a.scheduled_start_date && a.actual_start_date <= a.scheduled_start_date
      }]] },
  
      { name: "In Progress (late)", data: [["Audits", visible_audits.count { |a|
        a.status == "in_progress" && a.actual_start_date && a.scheduled_start_date && a.actual_start_date > a.scheduled_start_date
      }]] },
  
      { name: "Not Started", data: [["Audits", visible_audits.count { |a| a.status == "not_started" }]] }
    ]
  
    # Calculate suggested max for y-axis scaling
    max_value = @bar_chart_data.map { |s| s[:data][0][1] }.max
    suggested_max = (max_value * 1.1).ceil
  
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
    visible_audits = Audit
      .includes(:audit_assignments)
      .select { |audit|
        audit.audit_assignments.any? do |assignment|
          assignment.user_id == current_user.id && %w[lead_auditor auditor sme].include?(assignment.role)
        end
      }
  
    @pie_chart_data = {
      "Completed": visible_audits.select { |a| a.status == "completed" }.count, # Any
  
      "In Progress (on time)": visible_audits
                                .select { |a| a.status == "in_progress" && a.actual_start_date && a.scheduled_start_date && a.actual_start_date <= a.scheduled_start_date }
                                # .select { |a| a.actual_end_date && a.scheduled_end_date && a.actual_end_date <= a.scheduled_end_date }
                                .count, # to be replaced with scheduled_audits task
  
      "In Progress (late)": visible_audits
                                .select { |a| a.status == "in_progress" && a.actual_start_date && a.scheduled_start_date && a.actual_start_date > a.scheduled_start_date }
                                # .select { |a| a.actual_end_date && a.scheduled_end_date && a.actual_end_date > a.scheduled_end_date }
                                .count, # to be replaced with scheduled_audits task
  
      "Not Started": visible_audits.select { |a| a.status == "not_started" }.count
    }
  end
  
  def scheduled_audits
    @scheduled_audits = Audit
      .where(status: :not_started)
      .includes(audit_assignments: :user, audit_detail: :audit_standards)
      .select { |audit|
        audit.audit_assignments.any? do |assignment|
          assignment.user_id == current_user.id && %w[lead_auditor auditor sme].include?(assignment.role)
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
          assignment.user_id == current_user.id && %w[lead_auditor auditor sme].include?(assignment.role)
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
          assignment.user_id == current_user.id && %w[lead_auditor auditor sme].include?(assignment.role)
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


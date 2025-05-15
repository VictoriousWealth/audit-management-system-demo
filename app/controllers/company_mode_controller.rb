class CompanyModeController < ApplicationController
  before_action :authenticate_user!
  before_action :ensure_auditee!

  def company_mode
    scheduled_audits()
    in_progress_audits()
    completed_audits()

    pie_chart_data()
    bar_chart_data()
    compliance_score_graph_over_time()

    audit_findings()
    corrective_actions()
    documents()
    supplier_audit_histories()
  end

  private
  def supplier_audit_histories
    company_id = current_user.company_id
    return unless company_id
  
    # Vendor RPNs over time
    @vendor_rpns = VendorRpn.where(company_id: company_id).order(time_of_creation: :asc).map do |rpn|
      {
        date: rpn.time_of_creation.strftime("%Y-%m-%d"),
        material_criticality: rpn.material_criticality,
        compliance_history: rpn.supplier_compliance_history,
        regulatory_approvals: rpn.regulatory_approvals,
        complexity: rpn.supply_chain_complexity,
        performance: rpn.previous_supplier_performance,
        contamination_risk: rpn.contamination_adulteration_risk,
        rpn: rpn.calculate_rpn
      }
    end
  
    # Audit scores over time — only completed audits
    @audit_scores = Audit.where(company_id: company_id, status: :completed)
                        .where.not(score: nil)
                        .order(:actual_start_date)
                        .map do |audit|
      {
        date: audit.actual_start_date&.strftime("%Y-%m-%d"),
        score: audit.score
      }
    end

    # Risk levels over time
    @risk_levels = Audit.where(company_id: company_id).where.not(actual_end_date: nil ).order(:actual_end_date).map do |audit|
      {
        date: audit.actual_end_date&.strftime("%Y-%m-%d"),
        risk_level: risk_level(audit)
      }
    end
  end
  

  def documents
    auditee_ids = User.where(company_id: current_user.company_id, role: User.roles[:auditee]).pluck(:id)
  
    audit_ids = AuditAssignment.where(user_id: auditee_ids, role: AuditAssignment.roles[:auditee])
                               .pluck(:audit_id).uniq
  
    @documents = SupportingDocument.where(audit_id: audit_ids).map do |d|
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
  
    return unless current_user.company_id
  
    CorrectiveAction.includes(audit: [:company]).find_each do |c|
      audit = c.audit
      next unless audit
      next unless audit.company_id == current_user.company_id
  
      # Determine progress based on status enum
      progress = case c.status.to_sym
                 when :pending then 33  
                 when :in_progress then 66  
                 else 100       
                 end
  
      short_description = c.action_description.length > 15 ? "#{c.action_description[0...12]}..." : c.action_description
  
      company_name = audit.company&.name
  
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
    return unless current_user.company_id
  
    AuditFinding.includes(report: { audit: :company }).find_each do |finding|
      audit = finding.report&.audit
      next unless audit
      next unless audit.company_id == current_user.company_id
  
      category = case finding.category.to_sym
                 when :critical then "critical"
                 when :minor then "major"
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
  
  def compliance_score_graph_over_time
    compliance_score_graph_over_time_all()
    compliance_score_graph_over_time_day()
    compliance_score_graph_over_time_week()
    compliance_score_graph_over_time_month()
  end

  def compliance_score_graph_over_time_day
    today_range = Time.zone.today.beginning_of_day..Time.zone.today.end_of_day
  
    # All completed + scored audits today
    all_daily_audits = Audit.where.not(score: nil)
                            .where.not(actual_end_date: nil)
                            .where(actual_end_date: today_range)
                            .order(:actual_end_date)
  
    # Company-specific audits (My Audits)
    my_daily_audits = all_daily_audits.select { |a| a.company_id == current_user.company_id }
  
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
    current_week_range = Time.zone.now.beginning_of_week..Time.zone.now.end_of_week
  
    # All completed + scored audits in the current week
    all_weekly_audits = Audit.where.not(score: nil)
                             .where.not(actual_end_date: nil)
                             .where(actual_end_date: current_week_range)
                             .order(:actual_end_date)
  
    # Company-specific audits (My Audits)
    my_weekly_audits = all_weekly_audits.select { |a| a.company_id == current_user.company_id }
  
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
    current_month_range = Time.zone.now.beginning_of_month..Time.zone.now.end_of_month
  
    all_monthly_audits = Audit.where.not(score: nil)
                              .where.not(actual_end_date: nil)
                              .where(actual_end_date: current_month_range)
                              .order(:actual_end_date)
  
    my_monthly_audits = all_monthly_audits.select { |audit| audit.company_id == current_user.company_id }
  
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
    all_scored_audits = Audit.where.not(score: nil)
                             .where.not(actual_end_date: nil)
                             .order(:actual_end_date)
  
    my_scored_audits = all_scored_audits.select { |audit| audit.company_id == current_user.company_id }
  
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
    company_id = current_user.company_id
  
    visible_audits = Audit.where(company_id: company_id)
  
    @bar_chart_data = [
      { name: "Completed", data: [["Audits", visible_audits.count { |a| a.status == "completed" }]] },
  
      { name: "In Progress (on time)", data: [["Audits", visible_audits.count { |a|
        a.status == "in_progress" &&
        a.actual_start_date.present? &&
        a.scheduled_start_date.present? &&
        a.actual_start_date <= a.scheduled_start_date
      }]] },
  
      { name: "In Progress (late)", data: [["Audits", visible_audits.count { |a|
        a.status == "in_progress" &&
        a.actual_start_date.present? &&
        a.scheduled_start_date.present? &&
        a.actual_start_date > a.scheduled_start_date
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
    company_id = current_user.company_id
    visible_audits = Audit.where(company_id: company_id)
  
    @pie_chart_data = {
      "Completed": visible_audits.count { |a| a.status == "completed" },
  
      "In Progress (on time)": visible_audits.count { |a|
        a.status == "in_progress" &&
        a.actual_start_date.present? &&
        a.scheduled_start_date.present? &&
        a.actual_start_date <= a.scheduled_start_date
      },
  
      "In Progress (late)": visible_audits.count { |a|
        a.status == "in_progress" &&
        a.actual_start_date.present? &&
        a.scheduled_start_date.present? &&
        a.actual_start_date > a.scheduled_start_date
      },
  
      "Not Started": visible_audits.count { |a| a.status == "not_started" }
    }
  end
  
  def scheduled_audits
    company_id = current_user.company_id
  
    @scheduled_audits = Audit
      .where(status: :not_started, company_id: company_id)
      .includes(audit_assignments: :user, audit_detail: :audit_standards)
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
    company_id = current_user.company_id
  
    @in_progress_audits = Audit
      .where(status: :in_progress, company_id: company_id)
      .includes(audit_assignments: :user, audit_detail: :audit_standards)
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
    company_id = current_user.company_id
  
    @completed_audits = Audit
      .where(status: :completed, company_id: company_id)
      .includes(audit_assignments: :user, audit_detail: :audit_standards)
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

  def ensure_auditee!
    unless current_user.role == 'auditee'
      flash[:alert] = "Access denied: Only auditees can view that page."
      redirect_to dashboard_index_path
    end
  end
end


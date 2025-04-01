class QaDashboardController < ApplicationController
  def qa_manager
    scheduled_audits()
    in_progress_audits()
    completed_audits()

    pie_chart_data()
    bar_chart_data()
  end

  private

  def bar_chart_data
    @bar_chart_data_all = @pie_chart_data_all
  end
  def pie_chart_data
    @pie_chart_data_all = {
      completed_not_overdue: Audit.where(status: :completed)
                                  .where('actual_end_date <= scheduled_end_date')
                                  .count,
      in_progress_not_overdue: Audit.where(status: :in_progress)
                                    .where('actual_end_date <= scheduled_end_date')
                                    .count,
      completed_and_overdue: Audit.where(status: :completed)
                                  .where('actual_end_date > scheduled_end_date')
                                  .count,
      in_progress_and_overdue: Audit.where(status: :in_progress)
                                    .where('actual_end_date > scheduled_end_date')
                                    .count,
      not_started_and_overdue: Audit.where(status: :not_started)
                                    .where('? > scheduled_end_date', Time.now())
                                    .count,
      not_started_and_not_overdue: Audit.where(status: :not_started)
                                        .where('? < scheduled_end_date', Time.now())
                                        .count,
      pending_review: Audit.where(status: :pending_review).count,
    }

    # Here is the thought process:
      # completed refers to audits completed today -- use time of closure
      # in_progress refers to audits which dont have an actual end date some of these may overlap with overdue audits
      # completed refers to audits completed today -- use time of closure
      # completed refers to audits completed today -- use time of closure

    @pie_chart_data_by_day = {
      completed: Audit.where(status: :completed).where('? < time_of_creation AND time_of_creation < ?', ).count,
      in_progress: Audit.where(status: :in_progress).count,
      overdue: Audit.where('scheduled_end_date <= ?', Time.now).count, 
      not_started: Audit.where(status: :not_started).count,
      pending_review: Audit.where(status: :pending_review).count,
    }
  end

  def scheduled_audits
    @scheduled_audits = Audit.where(status: :not_started)
                              .includes(:audit_assignments => :user, :audit_detail => :audit_standards)
                              .map do |audit|
      lead_auditor = audit.audit_assignments.where(role: :lead_auditor).first&.user
      auditee = audit.audit_assignments.where(role: :auditee).first&.user
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
        rpn: VendorRpn.where(company_id: audit.company&.id).order(created_at: :desc).first&.calculate_rpn(),
      }
    end
  end

  def in_progress_audits
    @in_progress_audits = Audit.where(status: :in_progress)
                                .includes(:audit_assignments => :user)
                                .map do |audit|
      lead_auditor = audit.audit_assignments.where(role: :lead_auditor).first&.user
      auditee = audit.audit_assignments.where(role: :auditee).first&.user
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
        rpn: VendorRpn.where(company_id: audit.company&.id).order(created_at: :desc).first&.calculate_rpn(),
      }
    end
  end

  def completed_audits
    @completed_audits = Audit.where(status: :completed)
                              .includes(:audit_assignments => :user, :audit_detail => :audit_standards)
                              .map do |audit|
      lead_auditor = audit.audit_assignments.where(role: :lead_auditor).first&.user
      auditee = audit.audit_assignments.where(role: :auditee).first&.user
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
        rpn: VendorRpn.where(company_id: audit.company&.id).order(created_at: :desc).first&.calculate_rpn(),
        risk_level: risk_level(audit), 
      }
    end
  end

  def risk_level(audit)
    categories = AuditFinding.categories.keys # ["major", "minor", "critical"]
    category_counts = AuditFinding.where(report_id: Report.where(audit_id: audit.id).pluck(:id))
                                  .group(:category)
                                  .count

    category_counts = categories.each_with_object({}) do |category, hash|
      hash[category] = category_counts[category] || 0
    end

    if category_counts[:critical] >= 1
      "High Risk"
    elsif category_counts[:major] >= 5
      "High Risk"
    elsif category_counts[:minor] >= 5
      "Medium Risk"
    elsif category_counts[:major] >= 1
      "Medium Risk"
    else
      "Low Risk"
    end
  end
end

class QaDashboardController < ApplicationController
  before_action :authenticate_user!

  def qa_manager
    scheduled_audits()
    in_progress_audits()
    completed_audits()

    pie_chart_data()
    bar_chart_data()
    compliance_score_graph_over_time()
  end

  private
  def compliance_score_graph_over_time
    compliance_score_graph_over_time_all()
    compliance_score_graph_over_time_day()
    compliance_score_graph_over_time_week()
    compliance_score_graph_over_time_month()
  end

  def compliance_score_graph_over_time_day
    @compliance_score_by_day = [
      {
        name: "Internal",
        color: "#42CA68",
        data: Audit.where(audit_type: "internal")
                  .where.not(score: nil)
                  .where.not(actual_end_date: nil)
                  .where(actual_end_date: Time.zone.today.beginning_of_day..Time.zone.today.end_of_day)
                  .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "External",
        color: "#F39C12",
        data: Audit.where(audit_type: "external")
                  .where.not(score: nil)
                  .where.not(actual_end_date: nil)
                  .where(actual_end_date: Time.zone.today.beginning_of_day..Time.zone.today.end_of_day)
                  .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "All Audits",
        color: "#3498DB",
        data: Audit.where.not(score: nil)
                  .where.not(actual_end_date: nil)
                  .where(actual_end_date: Time.zone.today.beginning_of_day..Time.zone.today.end_of_day)
                  .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      }
    ]
  end

  def compliance_score_graph_over_time_week
    # @compliance_score_by_week = {}
    # @compliance_score_by_week_labels = {}
    @compliance_score_by_week = [
      {
        name: "Internal",
        color: "#42CA68",
        data: Audit.where(audit_type: "internal")
                  .where.not(score: nil)
                  .where.not(actual_end_date: nil)
                  .where(actual_end_date: Time.zone.now.beginning_of_week..Time.zone.now.end_of_week)
                  .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "External",
        color: "#F39C12",
        data: Audit.where(audit_type: "external")
                  .where.not(score: nil)
                  .where.not(actual_end_date: nil)
                  .where(actual_end_date: Time.zone.now.beginning_of_week..Time.zone.now.end_of_week)
                  .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "All Audits",
        color: "#3498DB",
        data: Audit.where.not(score: nil)
                  .where.not(actual_end_date: nil)
                  .where(actual_end_date: Time.zone.now.beginning_of_week..Time.zone.now.end_of_week)
                  .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      }
    ]
  end

  def compliance_score_graph_over_time_month
    # @compliance_score_by_month = {}
    # @compliance_score_by_month_labels = {}
    @compliance_score_by_month = [
      {
        name: "Internal",
        color: "#42CA68",
        data: Audit.where(audit_type: "internal")
                  .where.not(score: nil)
                  .where.not(actual_end_date: nil)
                  .where(actual_end_date: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month)
                  .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "External",
        color: "#F39C12",
        data: Audit.where(audit_type: "external")
                  .where.not(score: nil)
                  .where.not(actual_end_date: nil)
                  .where(actual_end_date: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month)
                  .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "All Audits",
        color: "#3498DB",
        data: Audit.where.not(score: nil)
                  .where.not(actual_end_date: nil)
                  .where(actual_end_date: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month)
                  .map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      }
    ]
  end

  def compliance_score_graph_over_time_all
    @compliance_score_all = [
      {
        name: "Internal",
        color: "#42CA68",
        data: Audit.where(audit_type: "internal").where.not(score: nil).where.not(actual_end_date: nil).order(:actual_end_date).map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      
      },
      {
        name: "External",
        color: "#F39C12",
        data: Audit.where(audit_type: "external").where.not(score: nil).where.not(actual_end_date: nil).order(:actual_end_date).map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      },
      {
        name: "All Audits",
        color: "#3498DB",
        data: Audit.where.not(score: nil).where.not(actual_end_date: nil).order(:actual_end_date).map { |audit| [audit.actual_end_date.strftime("%d-%b-%Y"), audit.score] }
      }
    ]
  end

  def bar_chart_data
    @bar_chart_data =@bar_chart_data = [
      { name: "Completed", data: [["Audits", Audit.where(status: :completed).count]] },
      { name: "In Progress (on time)", data: [["Audits", Audit.where(status: :in_progress).where('actual_start_date <= scheduled_start_date').count]] },
      { name: "In Progress (late)", data: [["Audits", Audit.where(status: :in_progress).where('actual_start_date > scheduled_start_date').count]] },
      { name: "Not Started", data: [["Audits", Audit.where(status: :not_started).count]] }
    ]
    
  end
  
  def pie_chart_data
    @pie_chart_data = {
      "Completed": Audit.where(status: :completed).count, # Any
      "In Progress (on time)": Audit.where(status: :in_progress)
                                    .where('actual_start_date <= scheduled_start_date')
                                    # .where('actual_end_date <= scheduled_end_date')
                                    .count, # to be replaced with scheduled_audits task
      "In Progress (late)": Audit.where(status: :in_progress)
                                    .where('actual_start_date > scheduled_start_date')
                                    # .where('actual_end_date > scheduled_end_date')
                                    .count, # to be replaced with scheduled_audits task
      "Not Started": Audit.where(status: :not_started)
                        .count,
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


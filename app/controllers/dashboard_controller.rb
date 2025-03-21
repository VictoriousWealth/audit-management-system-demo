class DashboardController < ApplicationController
  def index
    @audits = Audit.includes(:user, :company, :audit_detail).all

    @scheduled_audits = Audit
                          .where(status: :not_started)
                          .where.not(scheduled_start_date: nil, scheduled_end_date: nil)
                          .includes(:user, :company, :audit_detail)

    @completed_audits = Audit
                          .where(status: :completed)
                          .includes(:user, :company, :audit_detail)

    @in_progress_audits = Audit
                            .where(status: :in_progress)
                            .includes(:user, :company, :audit_detail)

    @to_be_scheduled_audits = Audit
                                .where(status: :not_started)
                                .where("scheduled_start_date IS NULL OR scheduled_end_date IS NULL")    
                                .includes(:user, :company, :audit_detail)

    # === Overall Counts ===
    completed_count = Audit.where(status: :completed).count
    in_progress_count = Audit.where(status: :in_progress).count
    not_started_count = Audit.where(status: :not_started).count
    total_count = completed_count + in_progress_count + not_started_count

    # === Helper to Calculate Percentages ===
    def compute_percentages(counts)
      total = counts.values.sum
      return {} if total.zero?

      counts.transform_values { |v| ((v.to_f / total) * 100).round(1) }
    end

    # === Pie Chart Data: All ===
    all_counts = {
      "Completed" => completed_count,
      "In Progress" => in_progress_count,
      "Not Started" => not_started_count
    }
    @pie_chart_data_all = compute_percentages(all_counts)

    # === Pie Chart Data: Day (Today) ===
    today_range = Time.zone.today.all_day
    day_counts = {
      "Completed" => Audit.where(status: :completed, created_at: today_range).count,
      "In Progress" => Audit.where(status: :in_progress, created_at: today_range).count,
      "Not Started" => Audit.where(status: :not_started, created_at: today_range).count
    }
    @pie_chart_data_by_day = compute_percentages(day_counts)

    # === Pie Chart Data: Week (Last 7 Days) ===
    week_range = Time.zone.now.beginning_of_week..Time.zone.now.end_of_week
    week_counts = {
      "Completed" => Audit.where(status: :completed, created_at: week_range).count,
      "In Progress" => Audit.where(status: :in_progress, created_at: week_range).count,
      "Not Started" => Audit.where(status: :not_started, created_at: week_range).count
    }
    @pie_chart_data_by_week = compute_percentages(week_counts)

    # === Pie Chart Data: Month (Last Month) ===
    month_range = Time.zone.now.beginning_of_month..Time.zone.now.end_of_month

    month_counts = {
      "Completed" => Audit.where(status: :completed, created_at: month_range).count,
      "In Progress" => Audit.where(status: :in_progress, created_at: month_range).count,
      "Not Started" => Audit.where(status: :not_started, created_at: month_range).count
    }
    @pie_chart_data_by_month = compute_percentages(month_counts)

    # === Bar Chart Data ===
    @chart_data_all = [
      { name: "Completed", data: [["Label", all_counts["Completed"]]] },
      { name: "In Progress", data: [["Label", all_counts["In Progress"]]] },
      { name: "Not Started", data: [["Label", all_counts["Not Started"]]] }
    ]
    @chart_data_by_month = [
      { name: "Completed", data: [["Label", month_counts["Completed"]]] },
      { name: "In Progress", data: [["Label", month_counts["In Progress"]]] },
      { name: "Not Started", data: [["Label", month_counts["Not Started"]]] }
    ]
    @chart_data_by_week = [
      { name: "Completed", data: [["Label", week_counts["Completed"]]] },
      { name: "In Progress", data: [["Label", week_counts["In Progress"]]] },
      { name: "Not Started", data: [["Label", week_counts["Not Started"]]] }      
    ]
    @chart_data_by_day = [
      { name: "Completed", data: [["Label", day_counts["Completed"]]] },
      { name: "In Progress", data: [["Label", day_counts["In Progress"]]] },
      { name: "Not Started", data: [["Label", day_counts["Not Started"]]] }      
    ]

  end
end

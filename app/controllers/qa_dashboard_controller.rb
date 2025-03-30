class QaDashboardController < ApplicationController
  def qa_manager
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
                                .includes(:user, :company, :audit_detail) # I dont remember why this line is neccessary

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

    # Compliance Score – Grouped by Time (Assume you calculate 'score')
    def compliance_score_data(range, group_by)
      Audit.where(created_at: range).group_by_period(group_by, :created_at, format: "%d %b").average(:score)
    end

    # Ranges
    today_range = Time.zone.today.all_day
    week_range = Time.zone.now.beginning_of_week..Time.zone.now.end_of_week
    month_range = Time.zone.now.beginning_of_month..Time.zone.now.end_of_month

    # Grouped Data
    # Daily Data (grouped by hour)
    @compliance_score_by_day = [
      { 
        name: "Your Compliance", 
        data: Audit.where(user: current_user, actual_end_date: today_range).group_by_period(:hour, :created_at, format: "%H:%M").average(:score)
      },
      { 
        name: "Org Compliance", 
        data: Audit.where(actual_end_date: today_range).group_by_period(:hour, :created_at, format: "%H:%M").average(:score)
      }
    ]
    
    # Weekly Data (grouped by day)
    @compliance_score_by_week = [
      { 
        name: "Your Compliance", 
        data: Audit.where(user: User.last, actual_end_date: week_range)
                  .group_by_period(:day, :actual_end_date, format: "%d %b")
                  .average(:score)
      },
      { 
        name: "Org Compliance", 
        data: Audit.where(actual_end_date: week_range)
                  .group_by_period(:day, :actual_end_date, format: "%d %b")
                  .average(:score)
      }
    ]

    # Monthly Data (grouped by month)
    @compliance_score_by_month = [
      { 
        name: "Your Compliance", 
        data: Audit.where(user: User.last, actual_end_date: month_range)
                   .group_by_period(:month, :actual_end_date, format: "%b %Y")
                   .average(:score)
      },
      { 
        name: "Org Compliance", 
        data: Audit.where(actual_end_date: month_range)
                   .group_by_period(:month, :actual_end_date, format: "%b %Y")
                   .average(:score)
      }
    ]
    
    # @compliance_score_all = Audit.group_by_month(:created_at, format: "%b %Y").average(:score)
    @compliance_score_all = [
      { 
        name: "Your Compliance", 
        data: Audit.where(user: User.last)
                   .group_by_period(:hour, :created_at, format: "%H:%M")
                   .average(:score)
      },
      { 
        name: "Org Compliance", 
        data: Audit.where(created_at: Audit.minimum(:created_at)..Time.zone.now)
                   .group_by_period(:hour, :created_at, format: "%H:%M")
                   .average(:score)
      }
    ]
    
    # Your vs Org Score (Today)
    @your_compliance_score = 67 #TODO: replace with real query for current user
    @org_compliance_score = Audit.average(:score)&.round


    # === Calendar Event Component ===
    
    today = Time.zone.today
    @calendar_events = []

    # === Category 1: Scheduled to End Per Date ===
    Audit.where.not(scheduled_end_date: nil).group("DATE(scheduled_end_date)").count.each do |date, count|
      @calendar_events << {
        title: "🔵#{count}",
        date: date,
        allDay: true,
        textColor: "#000",
        description: "#{count} audit(s) scheduled to end on #{date}"
      }
    end

    # === Category 2: Overdue Audits (status ≠ completed && end date < today) ===
    overdue_count = Audit.where.not(status: :completed)
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

    # === Category 3: Not Started + Missing Dates ===
    missing_dates_count = Audit.where(status: :not_started)
                               .where("scheduled_start_date IS NULL OR scheduled_end_date IS NULL")
                               .count

    if missing_dates_count > 0
      @calendar_events << {
        title: "🟡#{missing_dates_count}",
        date: today,
        allDay: true,
        textColor: "#000",
        description: "#{missing_dates_count} audit(s) missing start/end dates"
      }
    end
  end
end

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

    # === Chart Data ===
    @chart_data = {
      "Not Started" => Audit.where(status: :not_started).count,
      "In Progress" => Audit.where(status: :in_progress).count,
      "Completed" => Audit.where(status: :completed).count
    }
  end  
end

require 'rails_helper'

RSpec.describe QaDashboardController, type: :controller do
  # Creating a test user
  let(:qa_manager) { create(:user, role: "qa_manager", email: "qamanager@gmail.com") }
  
  # Actions to execute before any test
  before do
    # Signing in as a QA Manager
    sign_in qa_manager
  end

  describe 'GET #qa_manager' do
    it 'responds successfully' do
      get :qa_manager
      expect(response).to be_successful
    end

    it 'assigns scheduled_audits, in_progress_audits, and completed_audits' do
      allow(controller).to receive(:scheduled_audits).and_call_original
      allow(controller).to receive(:in_progress_audits).and_call_original
      allow(controller).to receive(:completed_audits).and_call_original

      get :qa_manager

      expect(controller).to have_received(:scheduled_audits)
      expect(controller).to have_received(:in_progress_audits)
      expect(controller).to have_received(:completed_audits)
    end

    it 'assigns chart data' do
      allow(controller).to receive(:pie_chart_data).and_call_original
      allow(controller).to receive(:bar_chart_data).and_call_original
      allow(controller).to receive(:compliance_score_graph_over_time).and_call_original

      get :qa_manager

      expect(controller).to have_received(:pie_chart_data)
      expect(controller).to have_received(:bar_chart_data)
      expect(controller).to have_received(:compliance_score_graph_over_time)
    end

    it 'assigns calendar events, audit findings, corrective actions, documents, and internal_vs_external' do
      %i[
        calendar_events
        audit_fidnings
        corrective_actions
        documents
        internal_vs_external
      ].each do |method|
        allow(controller).to receive(method).and_call_original
      end

      get :qa_manager

      %i[
        calendar_events
        audit_fidnings
        corrective_actions
        documents
        internal_vs_external
      ].each do |method|
        expect(controller).to have_received(method)
      end
    end
  end
end

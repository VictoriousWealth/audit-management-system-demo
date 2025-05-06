require 'rails_helper'
include ActiveJob::TestHelper

RSpec.describe CreateEditAuditsController, type: :controller do
  let!(:company) { Company.create!(name: "Test Co", city: "City", postcode: "S1 2FF", street_name: "Street") }

  let!(:qa_manager) { User.create!(email: "qa@test.com", password: "password123", role: :qa_manager) }
  let!(:senior_manager) { User.create!(email: "sm@test.com", password: "password123", role: :senior_manager) }
  let!(:lead_auditor) { User.create!(email: "lead@test.com", password: "password123", role: :auditor) }
  let!(:support_auditor) { User.create!(email: "support@test.com", password: "password123", role: :auditor) }
  let!(:unassigned_auditor) { User.create!(email: "none@test.com", password: "password123", role: :auditor) }
  let!(:other_qa) { User.create!(email: "other.qa@test.com", password: "password123", role: :qa_manager) }
  let!(:sme) { User.create!(email: "sme@test.com", password: "password123", role: :sme) }
  let!(:auditee) { User.create!(email: "auditee@test.com", password: "password123", role: :auditee) }

  let!(:audit) {
    Audit.create!(
      company_id: company.id,
      audit_type: "internal",
      scheduled_start_date: Date.today,
      scheduled_end_date: Date.today + 1.day,
      status: :not_started,
      time_of_creation: Time.now
    )
  }

  let!(:audit_detail) {
    AuditDetail.create!(
      audit: audit,
      scope: "scope",
      objectives: "objectives",
      purpose: "purpose",
      boundaries: "boundaries"
    )
  }

  let!(:assignment_lead) {
    audit.audit_assignments.create!(
      user: lead_auditor,
      role: :lead_auditor,
      assigned_by: qa_manager.id,
      status: :assigned
    )
  }

  let!(:assignment_support) {
    audit.audit_assignments.create!(
      user: support_auditor,
      role: :auditor,
      assigned_by: qa_manager.id,
      status: :assigned
    )
  }

  describe "POST #create" do
    it "successfully creates an audit with valid nested params" do
      sign_out :user
      sign_in qa_manager

      expect {
        post :create, params: {
          commit: "Create Audit",
          company: {
            id: company.id
          },
          audit: {
            audit_type: "internal",
            scheduled_start_date: Date.today.to_s,
            scheduled_end_date: (Date.today + 1.day).to_s
          },
          audit_detail: {
            scope: "Scope of audit",
            objectives: "Audit objectives",
            purpose: "Audit purpose",
            boundaries: "Audit boundaries"
          },
          audit_standard: {
            standard: ["ISO 9001", "GMP"]
          },
          audit_assignment: {
            lead_auditor: lead_auditor.id,
            auditee: auditee.id,
            support_auditor: [support_auditor.id],
            sme: [sme.id]
          }
        }
      }.to change(Audit, :count).by(1)
       .and change(AuditDetail, :count).by(1)
       .and change(AuditAssignment, :count).by(4)
       .and change(AuditStandard, :count).by(2)

      created_audit = Audit.last
      expect(response).to redirect_to(edit_create_edit_audit_path(created_audit))
    end

    it "fails to create audit when required fields are missing" do
      sign_out :user
      sign_in qa_manager
    
      expect {
        post :create, params: {
          commit: "Create Audit",
          company: {
            id: nil # missing company id
          },
          audit: {
            audit_type: nil,
            scheduled_start_date: nil,
            scheduled_end_date: nil
          },
          audit_detail: {
            scope: nil,
            objectives: nil,
            purpose: nil,
            boundaries: nil
          },
          audit_standard: {
            standard: [] # optional
          },
          audit_assignment: {
            lead_auditor: nil,
            auditee: nil,
            support_auditor: [],
            sme: []
          }
        }
      }.not_to change(Audit, :count)
    
      expect(response).to render_template(:new)
      expect(flash.now[:alert]).to be_present
    end
    
    it "rolls back audit creation if AuditDetail fails to save" do
      sign_out :user
      sign_in qa_manager
    
      # Simulate invalid `audit_detail[:purpose]` (e.g., too long)
      long_purpose = "x" * 10_000 # Assuming this breaks validation
    
      expect {
        post :create, params: {
          commit: "Create Audit",
          company: {
            id: company.id
          },
          audit: {
            audit_type: "internal",
            scheduled_start_date: Date.today.to_s,
            scheduled_end_date: (Date.today + 1.day).to_s
          },
          audit_detail: {
            scope: "Valid scope",
            objectives: "Valid objectives",
            purpose: long_purpose, # Invalid on purpose
            boundaries: "Valid boundaries"
          },
          audit_standard: {
            standard: ["ISO 9001"]
          },
          audit_assignment: {
            lead_auditor: lead_auditor.id,
            auditee: auditee.id,
            support_auditor: [],
            sme: []
          }
        }
      }.not_to change(Audit, :count)
    
      expect(response).to render_template(:new)
      expect(flash.now[:alert]).to include("Something went wrong with saving this audit's details")
    end

    it "rolls back audit creation if AuditAssignment (lead auditor) is missing" do
      sign_out :user
      sign_in qa_manager
    
      expect {
        post :create, params: {
          commit: "Create Audit",
          company: {
            id: company.id
          },
          audit: {
            audit_type: "internal",
            scheduled_start_date: Date.today.to_s,
            scheduled_end_date: (Date.today + 1.day).to_s
          },
          audit_detail: {
            scope: "Scope of audit",
            objectives: "Objectives of audit",
            purpose: "Purpose of audit",
            boundaries: "Boundaries of audit"
          },
          audit_standard: {
            standard: ["ISO 9001"]
          },
          audit_assignment: {
            lead_auditor: nil, # <-- lead auditor missing
            auditee: auditee.id,
            support_auditor: [],
            sme: []
          }
        }
      }.not_to change(Audit, :count)
    
      expect(response).to render_template(:new)
      expect(flash.now[:alert]).to include("Please fill in the following required fields: ")
    end

    it "gracefully handles missing audit_detail params on create" do
      sign_out :user
      sign_in qa_manager
    
      expect {
        post :create, params: {
          commit: "Create Audit",
          company: {
            id: company.id
          },
          audit: {
            audit_type: "internal",
            scheduled_start_date: Date.today.to_s,
            scheduled_end_date: (Date.today + 1.day).to_s
          },
          # Missing audit_detail entirely
          audit_assignment: {
            lead_auditor: lead_auditor.id,
            auditee: auditee.id,
            support_auditor: [],
            sme: []
          }
        }
      }.not_to change(Audit, :count)
    
      expect(response).to render_template(:new)
      expect(flash.now[:alert]).to be_present
    end
    
    it "prevents SME from creating an audit even with valid params" do
      sign_out :user
      sign_in sme
    
      expect {
        post :create, params: {
          commit: "Create Audit",
          company: { id: company.id },
          audit: {
            audit_type: "internal",
            scheduled_start_date: Date.today.to_s,
            scheduled_end_date: (Date.today + 1.day).to_s
          },
          audit_detail: {
            scope: "Scope",
            objectives: "Objectives",
            purpose: "Purpose",
            boundaries: "Boundaries"
          },
          audit_standard: {
            standard: ["ISO 9001"]
          },
          audit_assignment: {
            lead_auditor: lead_auditor.id,
            auditee: auditee.id,
            support_auditor: [],
            sme: []
          }
        }
      }.not_to change(Audit, :count)
    
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include("not authorized")
    end
    
    it "enqueues AuditMailer.notify_assignment for each assigned user after create" do
      sign_out :user
      sign_in qa_manager
    
      perform_enqueued_jobs do
        expect {
          post :create, params: {
            commit: "Create Audit",
            company: {
              id: company.id
            },
            audit: {
              audit_type: "internal",
              scheduled_start_date: Date.today.to_s,
              scheduled_end_date: (Date.today + 1.day).to_s
            },
            audit_detail: {
              scope: "Scope of audit",
              objectives: "Objectives of audit",
              purpose: "Purpose of audit",
              boundaries: "Boundaries of audit"
            },
            audit_standard: {
              standard: ["ISO 9001", "GMP"]
            },
            audit_assignment: {
              lead_auditor: lead_auditor.id,
              auditee: auditee.id,
              support_auditor: [support_auditor.id],
              sme: [sme.id]
            }
          }
        }.to change(Audit, :count).by(1)
      end
    
      # Verify mail jobs were enqueued
      expect(enqueued_jobs.count { |job| job[:args][0] == "AuditMailer" && job[:args][1] == "notify_assignment" }).to eq(4)
    end
    
  end


  describe "PATCH #update" do
    it "successfully updates audit, detail, standards, and assignments" do
      sign_out :user
      sign_in qa_manager

      patch :update, params: {
        id: audit.id,
        commit: "Update Audit",
        company: {
          id: company.id
        },
        audit: {
          audit_type: "external", # changed
          scheduled_start_date: Date.today.to_s,
          scheduled_end_date: (Date.today + 2.days).to_s,
          actual_start_date: Date.today.to_s,
          actual_end_date: (Date.today + 1.day).to_s
        },
        audit_detail: {
          scope: "Updated scope",
          objectives: "Updated objectives",
          purpose: "Updated purpose",
          boundaries: "Updated boundaries"
        },
        audit_standard: {
          standard: ["MHRA", "GMP"] # changed from initial
        },
        audit_assignment: {
          lead_auditor: lead_auditor.id,
          auditee: auditee.id,
          support_auditor: [support_auditor.id],
          sme: [sme.id]
        }
      }

      updated_audit = Audit.find(audit.id)
      updated_detail = updated_audit.audit_detail

      expect(updated_audit.audit_type).to eq("external")
      expect(updated_audit.actual_start_date.to_date).to eq(Date.today)
      expect(updated_audit.actual_end_date.to_date).to eq(Date.today + 1.day)

      expect(updated_detail.scope).to eq("Updated scope")
      expect(updated_detail.objectives).to eq("Updated objectives")
      expect(updated_detail.purpose).to eq("Updated purpose")
      expect(updated_detail.boundaries).to eq("Updated boundaries")

      expect(updated_detail.audit_standards.pluck(:standard)).to contain_exactly("MHRA", "GMP")
      expect(updated_audit.audit_assignments.count).to eq(4) # lead, auditee, support, SME

      expect(response).to redirect_to(edit_create_edit_audit_path(updated_audit))
      expect(flash[:notice]).to eq("Audit updated successfully.")
    end

    it "does not update audit when required fields are missing" do
      sign_out :user
      sign_in qa_manager
    
      original_audit_type = audit.audit_type
      original_detail = audit.audit_detail.attributes.slice("scope", "objectives", "purpose", "boundaries")
    
      patch :update, params: {
        id: audit.id,
        commit: "Update Audit",
        company: {
          id: "" # missing company ID
        },
        audit: {
          audit_type: "",
          scheduled_start_date: "",
          scheduled_end_date: "",
          actual_start_date: "",
          actual_end_date: ""
        },
        audit_detail: {
          scope: "",
          objectives: "",
          purpose: "",
          boundaries: ""
        },
        audit_standard: {
          standard: []
        },
        audit_assignment: {
          lead_auditor: "",
          auditee: "",
          support_auditor: [],
          sme: []
        }
      }
    
      audit.reload
      audit_detail = audit.audit_detail
    
      # Confirm no changes were saved
      expect(audit.audit_type).to eq(original_audit_type)
      expect(audit_detail.attributes.slice("scope", "objectives", "purpose", "boundaries")).to eq(original_detail)
    
      # Confirm response is re-rendered with flash alert
      expect(response).to render_template(:edit)
      expect(flash.now[:alert]).to be_present
    end
    
    it "fails to update when AuditDetail is missing" do
      sign_out :user
      sign_in qa_manager
    
      # Simulate missing AuditDetail
      audit.audit_detail.destroy
    
      patch :update, params: {
        id: audit.id,
        commit: "Update Audit",
        company: {
          id: company.id
        },
        audit: {
          audit_type: "external",
          scheduled_start_date: Date.today.to_s,
          scheduled_end_date: (Date.today + 2.days).to_s,
          actual_start_date: Date.today.to_s,
          actual_end_date: (Date.today + 1.day).to_s
        },
        audit_detail: {
          scope: "New scope",
          objectives: "New objectives",
          purpose: "New purpose",
          boundaries: "New boundaries"
        },
        audit_standard: {
          standard: ["GMP"]
        },
        audit_assignment: {
          lead_auditor: lead_auditor.id,
          auditee: auditee.id,
          support_auditor: [],
          sme: []
        }
      }
    
      expect(response).to render_template(:edit)
      expect(flash.now[:alert]).to include("Something went wrong while updating this audit's details")
    end
    
    it "gracefully handles missing audit_detail params on update" do
      sign_out :user
      sign_in qa_manager
    
      patch :update, params: {
        id: audit.id,
        commit: "Update Audit",
        company: {
          id: company.id
        },
        audit: {
          audit_type: "external",
          scheduled_start_date: Date.today.to_s,
          scheduled_end_date: (Date.today + 2.days).to_s,
          actual_start_date: Date.today.to_s,
          actual_end_date: (Date.today + 1.day).to_s
        },
        # Missing audit_detail entirely
        audit_assignment: {
          lead_auditor: lead_auditor.id,
          auditee: auditee.id,
          support_auditor: [],
          sme: []
        }
      }
    
      expect(response).to render_template(:edit)
      expect(flash.now[:alert]).to be_present
    end
    
    it "prevents Auditee from updating an audit even with valid params" do
      sign_out :user
      sign_in auditee
    
      patch :update, params: {
        id: audit.id,
        commit: "Update Audit",
        company: {
          id: company.id
        },
        audit: {
          audit_type: "external",
          scheduled_start_date: Date.today.to_s,
          scheduled_end_date: (Date.today + 2.days).to_s,
          actual_start_date: Date.today.to_s,
          actual_end_date: (Date.today + 1.day).to_s
        },
        audit_detail: {
          scope: "New scope",
          objectives: "New objectives",
          purpose: "New purpose",
          boundaries: "New boundaries"
        },
        audit_standard: {
          standard: ["GMP"]
        },
        audit_assignment: {
          lead_auditor: lead_auditor.id,
          auditee: auditee.id,
          support_auditor: [],
          sme: []
        }
      }
    
      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to include("not authorized")
    end
    
    it "enqueues AuditMailer.update_audit for each assigned user after update" do
      sign_out :user
      sign_in qa_manager
    
      perform_enqueued_jobs do
        patch :update, params: {
          id: audit.id,
          commit: "Update Audit",
          company: {
            id: company.id
          },
          audit: {
            audit_type: "external",
            scheduled_start_date: Date.today.to_s,
            scheduled_end_date: (Date.today + 2.days).to_s,
            actual_start_date: Date.today.to_s,
            actual_end_date: (Date.today + 1.day).to_s
          },
          audit_detail: {
            scope: "Updated scope",
            objectives: "Updated objectives",
            purpose: "Updated purpose",
            boundaries: "Updated boundaries"
          },
          audit_standard: {
            standard: ["MHRA"]
          },
          audit_assignment: {
            lead_auditor: lead_auditor.id,
            auditee: auditee.id,
            support_auditor: [support_auditor.id],
            sme: [sme.id]
          }
        }
      end
    
      # Verify mail jobs were enqueued
      expect(enqueued_jobs.count { |job| job[:args][0] == "AuditMailer" && job[:args][1] == "update_audit" }).to eq(4)
    end
    
  end

  describe "#block_sme_and_auditee" do
    it "redirects SME to root path with alert when accessing new audit page" do
      sign_out :user
      sign_in sme # assuming `sme` is a valid user with the SME role

      # Simulate a GET request to the `new` action, which triggers the `before_action`
      get :new

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "redirects Auditee to root path with alert when accessing new audit page" do
      sign_out :user
      sign_in auditee # assuming `auditee` is a valid user with the Auditee role

      # Simulate a GET request to the `new` action, which triggers the `before_action`
      get :new

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "redirects SME to root path with alert when creating an audit" do
      sign_out :user
      sign_in sme

      # Simulate a POST request to the `create` action, which triggers the `before_action`
      post :create, params: { audit: { audit_type: 'internal', scheduled_start_date: Date.today.to_s, scheduled_end_date: (Date.today + 1.day).to_s } }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end

    it "redirects Auditee to root path with alert when creating an audit" do
      sign_out :user
      sign_in auditee

      # Simulate a POST request to the `create` action, which triggers the `before_action`
      post :create, params: { audit: { audit_type: 'internal', scheduled_start_date: Date.today.to_s, scheduled_end_date: (Date.today + 1.day).to_s } }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to access this page.")
    end
  end

  describe "#authorize_creation" do
    let(:company) { create(:company) }  # Ensure you create a company in your test

    it "redirects unprivileged user (auditor) from creating audits" do
      sign_out :user
      sign_in support_auditor

      # Simulate a POST request to the `create` action, passing the company_id
      post :create, params: { 
        commit: "Create Audit",
        company: {
          id: company.id
        },
        audit: {
          audit_type: "internal",
          scheduled_start_date: Date.today.to_s,
          scheduled_end_date: (Date.today + 1.day).to_s
        },
        audit_detail: {
          scope: "Scope of audit",
          objectives: "Objectives of audit",
          purpose: "Purpose of audit",
          boundaries: "Boundaries of audit"
        },
        audit_standard: {
          standard: ["ISO 9001", "GMP"]
        },
        audit_assignment: {
          lead_auditor: lead_auditor.id,
          auditee: auditee.id,
          support_auditor: [support_auditor.id],
          sme: [sme.id]
        }
      }

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to create new audits.")
    end

    it "allows senior_manager to create audits" do
      sign_out :user
      sign_in senior_manager

      # Simulate a POST request to the `create` action, passing the company_id
      post :create, params: { 
        commit: "Create Audit",
        company: {
          id: company.id
        },
        audit: {
          audit_type: "internal",
          scheduled_start_date: Date.today.to_s,
          scheduled_end_date: (Date.today + 1.day).to_s
        },
        audit_detail: {
          scope: "Scope of audit",
          objectives: "Objectives of audit",
          purpose: "Purpose of audit",
          boundaries: "Boundaries of audit"
        },
        audit_standard: {
          standard: ["ISO 9001", "GMP"]
        },
        audit_assignment: {
          lead_auditor: lead_auditor.id,
          auditee: auditee.id,
          support_auditor: [support_auditor.id],
          sme: [sme.id]
        }
      }

      # Expecting a redirecct response status
      expect(response.status).to eq(302) 
    end

    it "allows qa_manager to create audits" do
      sign_out :user
      sign_in qa_manager

      # Simulate a POST request to the `create` action, passing the company_id
      post :create, params: { 
        commit: "Create Audit",
        company: {
          id: company.id
        },
        audit: {
          audit_type: "internal",
          scheduled_start_date: Date.today.to_s,
          scheduled_end_date: (Date.today + 1.day).to_s
        },
        audit_detail: {
          scope: "Scope of audit",
          objectives: "Objectives of audit",
          purpose: "Purpose of audit",
          boundaries: "Boundaries of audit"
        },
        audit_standard: {
          standard: ["ISO 9001", "GMP"]
        },
        audit_assignment: {
          lead_auditor: lead_auditor.id,
          auditee: auditee.id,
          support_auditor: [support_auditor.id],
          sme: [sme.id]
        }
      }


      # Expecting a redirect response status
      expect(response.status).to eq(302) 
    end
  end

  describe "#authorize_editing" do
    before do
      @audit = audit
      @request.params[:id] = @audit.id
    end

    it "allows QA Manager who assigned the audit" do
      sign_out :user
      sign_in qa_manager

      expect {
        controller.send(:authorize_editing)
      }.not_to raise_error
    end

    it "denies QA Manager who did NOT assign the audit" do
      sign_out :user
      sign_in other_qa

      controller.request.env["HTTP_REFERER"] = root_path
      expect {
        controller.send(:authorize_editing)
      }.to change { response.status }.to(302)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to edit this audit.")
    end

    it "allows assigned auditor (lead_auditor)" do
      sign_out :user
      sign_in lead_auditor

      expect {
        controller.send(:authorize_editing)
      }.not_to raise_error
    end

    it "allows assigned auditor (support_auditor)" do
      sign_out :user
      sign_in support_auditor

      expect {
        controller.send(:authorize_editing)
      }.not_to raise_error
    end

    it "denies unassigned auditor" do
      sign_out :user
      sign_in unassigned_auditor

      controller.request.env["HTTP_REFERER"] = root_path
      expect {
        controller.send(:authorize_editing)
      }.to change { response.status }.to(302)

      expect(response).to redirect_to(root_path)
      expect(flash[:alert]).to eq("You are not authorized to edit this audit.")
    end
  end


  shared_examples "can access edit and update" do |user_symbol|
    it "#{user_symbol} can GET #edit" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      get :edit, params: { id: audit.id }
      expect(controller.current_user).to eq(user)
      expect(response).to have_http_status(:ok)
    end
  
    it "#{user_symbol} can PATCH #update (discard)" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      patch :update, params: { id: audit.id, commit: "Discard Edits" }
      expect(response).to have_http_status(:found)
    end
  end
  
  shared_examples "cannot access edit and update" do |user_symbol|
    it "#{user_symbol} is denied GET #edit" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      get :edit, params: { id: audit.id }
      expect(response).to redirect_to(root_path).or have_http_status(:forbidden)
    end
  
    it "#{user_symbol} is denied PATCH #update" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      patch :update, params: { id: audit.id, commit: "Discard Edits" }
      expect(response).to redirect_to(root_path).or have_http_status(:forbidden)
    end
  end
  
  shared_examples "can access new and create" do |user_symbol|
    it "#{user_symbol} can GET #new" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      get :new
      expect(response).to have_http_status(:ok)
    end
  
    it "#{user_symbol} can POST #create (Discard Edits)" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      post :create, params: { commit: "Discard Edits" }
      expect(response).to have_http_status(:found)
    end
  end
  
  shared_examples "cannot access new and create" do |user_symbol|
    it "#{user_symbol} is denied GET #new" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      get :new
      expect(response).to redirect_to(root_path).or have_http_status(:forbidden)
    end
  
    it "#{user_symbol} is denied POST #create" do
      user = send(user_symbol)
      sign_out :user
      sign_in user
      post :create, params: {}
      expect(response).to redirect_to(root_path).or have_http_status(:forbidden)
    end
  end

  
  # Allowed roles
  include_examples "can access edit and update", :senior_manager
  include_examples "can access edit and update", :qa_manager
  include_examples "can access edit and update", :lead_auditor
  include_examples "can access edit and update", :support_auditor

  # Not allowed
  include_examples "cannot access edit and update", :unassigned_auditor
  include_examples "cannot access edit and update", :other_qa
  include_examples "cannot access edit and update", :sme
  include_examples "cannot access edit and update", :auditee

  include_examples "can access new and create", :qa_manager
  include_examples "can access new and create", :senior_manager

  include_examples "cannot access new and create", :lead_auditor
  include_examples "cannot access new and create", :support_auditor
  include_examples "cannot access new and create", :sme
  include_examples "cannot access new and create", :auditee

  context "when unauthenticated" do
    it "redirects GET #new to root" do
      get :new
      expect(response).to redirect_to(new_user_session_path)
    end
  
    it "redirects POST #create to root" do
      post :create, params: {}
      expect(response).to redirect_to(new_user_session_path)
    end
  
    it "redirects GET #edit to root" do
      get :edit, params: { id: audit.id }
      expect(response).to redirect_to(new_user_session_path)
    end
  
    it "redirects PATCH #update to root" do
      patch :update, params: { id: audit.id }
      expect(response).to redirect_to(new_user_session_path)
    end
  end  
end

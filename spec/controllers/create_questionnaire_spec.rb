# Loading the Rails frameworks and all of the application code
require 'rails_helper'

RSpec.describe QuestionnairesController, type: :controller do  
  # Creating test users
  let(:qa_manager) { create(:user, role: "qa_manager", email: "qamanager@gmail.com") }
  let(:auditee) { create(:user, role: "auditee", email: "auditee@gmail.com") }

  # Creating a custom questionnaire, section, question, and section question
  let!(:question) { create(:question_bank, question_text: "Do you wear wigs?") }
  let!(:section_question) { create(:section_question, questionnaire_section_id: section.id, question_bank_id: question.id) }
  let!(:custom_questionnaire) { create(:custom_questionnaire, name: "YCD - Supplier Approval Guidance Pre Qualification Questionnaire", user: qa_manager) }
  let!(:section) { create(:questionnaire_section, custom_questionnaire_id: custom_questionnaire.id, section_order: 1) }

  # Actions to execute before any test
  before do
    # Signing in as a QA Manager
    sign_in qa_manager
  end
  
  # Tests for rendering the page
  describe "GET #new" do
    it "renders the create questionnaire page if authorized" do
      get :new
      expect(response).to render_template(:new)
      expect(assigns(:custom_questionnaire)).to be_a_new(CustomQuestionnaire)
    end

    it "redirects an unauthorized user" do
      sign_out qa_manager
      sign_in auditee
      get :new
      expect(response).to redirect_to(root_path)
    end
  end

  # Test for creating a basic custom questionnaire
  describe "POST #create" do
    # Params for the questionnaire
    let(:questionnaire_params) do
      {
        title: "Test Questionnaire",
        data: [
          {
            name: "Section 1",
            id: 1,
            questions: ["Question 1", "Question 2"]
          }
        ]
      }
    end

    # Creating the custom questionnaire, questionnaire sections, 
    # section questions, and question bank questions
    it "creates a custom questionnaire and its database entries" do
      # Expecting changes to the database tables when creating the questionnaire
      expect { post :create, params: questionnaire_params }
        .to change(CustomQuestionnaire, :count).by(1)
        .and change(QuestionnaireSection, :count).by(1)
        .and change(SectionQuestion, :count).by(2)
        .and change(QuestionBank, :count).by(2)

      # Expecting a success response and message
      expect(response).to have_http_status(:success)
      expect(JSON.parse(response.body)["message"]).to eq("Custom questionnaire created successfully")
    end
  end

  # Tests for getting the edit question page/modal
  describe "GET #_edit_question" do

    # Creating the section question beforehand
    before do
      create(:section_question, question_bank: question, questionnaire_section: section)
    end

    # Test for editing an existing question
    context "GET #edit_question" do
      it "gets the correct question and renders the template" do
        # Passing in question id and section id to the method
        get :edit_question, params: { id: question.id, section_id: section.id }
        # Expecting @question to equal the test question
        expect(assigns(:question)).to eq(question)
        # Expecting @questionnaire_section to equal the test section
        expect(assigns(:questionnaire_section)).to eq(section)
        # Expecting the page to be rendered
        expect(response).to render_template("edit_question")
      end
    end

    # Test for editing a new question
    context "POST #edit_new_question" do
      it "sends information for the new question and renders the template" do
        question_order_id = "9" # the ninth question on the page
        # Passing in the question text, question order, and section id
        get :edit_new_question, params: { 
          question_text: question.question_text, 
          id: question_order_id, 
          questionnaire_section_id: section.id
        }

        # Expecting the controller variables to equal the test variables
        expect(assigns(:question_text)).to eq(question.question_text)
        expect(assigns(:new_question_id)).to eq(question_order_id.to_i + 1)
        expect(assigns(:section)).to eq(section)

        question = assigns(:question) # getting @question from the controller
        # Expecting the question to have certain properties
        expect(question).to be_a(QuestionBank)
        expect(question.question_text).to eq(question.question_text)

        # Expexting the page to be rendered
        expect(response).to render_template("edit_new_question")
      end
    end
  end

  # Test for updating the questionnaire layout after selecting a template questionnaire
  describe "POST #show" do
    context "when the questionnaire exists with sections and questions" do
      it "returns a built JSON with sections and questions" do
        cq = CustomQuestionnaire.find_by(name: custom_questionnaire.name)
        sec = QuestionnaireSection.find_by(custom_questionnaire: custom_questionnaire)
        q = QuestionBank.find_by(question_text: question.question_text)
        sq = SectionQuestion.find_by(questionnaire_section_id: section.id)

        expect(q).not_to be(nil)
        expect(sq).not_to be(nil)
        expect(cq).not_to be(nil)
        expect(sec).not_to be(nil)

        # Posting to the method with its params
        post :show, params: { name: custom_questionnaire.name }
        # Parsing the response JSON
        json = JSON.parse(response.body)
        
        # Expecting an OK response and for the JSON to be structured accordingly
        expect(response).to have_http_status(:ok)
        expect(json["sections"]).to be_an(Array)
        expect(json["sections"].first["name"]).to eq(section.name)
        expect(json["sections"].first["questions"].first["question_text"]).to eq(question.question_text)
      end
    end

    context "when the questionnaire does not exist" do
      it "returns an empty array" do
        # Posting to the method with its params
        post :show, params: { name: "Moisturize me!" }
        # Parsing the response JSON
        json = JSON.parse(response.body)

        # Expecting an OK response and for it to be []
        expect(response).to have_http_status(:ok)
        expect(json["sections"]).to eq([])
      end
    end
  end

  # Test for updating the questionnaire layout after selecting a template questionnaire
  describe "POST #update_questionnaire_layout" do
    it "returns a structured JSON of the page layout" do
       # Posting to the method with its params
      post :update_questionnaire_layout, params: { questionnaire_type: custom_questionnaire.name }
      # Parsing the response JSON
      json = JSON.parse(response.body)

      # Expecting an OK response and for the JSON to be structured accordingly
      expect(response).to have_http_status(:ok)
      expect(json["sections"]).to be_an(Array)
      expect(json["sections"].first["name"]).to eq(section.name)
      expect(json["sections"].first["questions"].first["question_text"]).to eq(question.question_text)
    end
  end

  # Test for rendering the edit section modal and editing a section's name
  describe "GET #_edit_section" do
    it "renders the edit section modal" do
      # Getting the method with the params
      get :edit_section, params: { id: section.id }

      # Expecting the controller variables to be defined correctly
      expect(assigns(:question_section)).to eq(section)
      expect(assigns(:section_with_question_ids).first).to eq(section_question)
      expect(assigns(:section)).to eq(section_question)

      # Expexting the page to be rendered
      expect(response).to render_template("edit_section")
    end
  end

  # Test for rendering the add question modal
  describe "POST #add_question" do
    it "renders the add question modal" do
      # Posting the method with the params
      post :add_question, params: { 
        section_order: section.section_order, 
        section_name: section.name,
        list_index: "9",
        questionnaire_section_id: section.id
      }

      # Expect @question to be a QuestionBank
      expect(assigns(:question)).to be_a(QuestionBank)
      # Expecting the page to be rendered
      expect(response).to render_template("add_question")
    end
  end

  # Test for rendering the add question bank question modal
  describe "POST #add_question_bank_question" do
    it "renders the add question bank question" do
      # Posting the method with the params
      post :add_question_bank_question, params: {
        section_order: section.section_order,
        section_name: section.name,
        list_index: "9",
        questionnaire_section_id: section.id
      }

      # Expect @question to be a QuestionBank
      expect(assigns(:question)).to be_a(QuestionBank)
    end
  end

  # Test for retrieving a questionnaire's sections and questions
  describe "POST #get_questionnaire_questions" do
    it "retrieves the structures questionnaire sections and questions" do
      # Posting the method with the params
      post :get_questionnaire_questions, params: { questionnaire_type: custom_questionnaire.name }

      # Parsing the response JSON
      json = JSON.parse(response.body)

      # Expecting an OK response and for the JSON to be structured accordingly
      expect(response).to have_http_status(:ok)
      expect(json["sections"]).to be_an(Array)
      expect(json["sections"].first["name"]).to eq(section.name)
      expect(json["sections"].first["questions"].first["question_text"]).to eq(question.question_text)
    end
  end
end
class QuestionnairesController < ApplicationController
  # Methods to run before executing any other methods
  layout 'questionnaire_layout'
  before_action :get_questionnaires, only: [:new, :create, :edit, :add_question_bank_question]
  before_action :authenticate_user!

  # Retrieving data for rendering the page
  def new
    # Building the questionnaire and sections
    @custom_questionnaire = CustomQuestionnaire.new
    @sections = @custom_questionnaire.questionnaire_sections.build
  end

  # Creating and saving the questionnaire to the database
  def create
    title = params[:title] # the inputted name of the questionnaire
    data = params[:data] # the section and question data submitted

    # Creating the custom questionnaire
    @custom_questionnaire = CustomQuestionnaire.create(name: title, user_id: current_user.id)

    data.map do |sq|
      # Making each section in the questionnaire
      questionnaire_section = QuestionnaireSection.create(name: sq[:name], section_order: sq[:id], custom_questionnaire_id: @custom_questionnaire.id)
      questions = sq[:questions] # the section's questions
      
      questions.map do |q|
        # Adding the question if it doesn't already exist
        question_bank_question = QuestionBank.where(question_text: q).first

        if (question_bank_question == nil)
          QuestionBank.create(question_text: q)
        end

        # The current question in the database
        currQuestion = QuestionBank.where(question_text: q).first
    
        # Creating the corresponding Section Question
        SectionQuestion.create(question_bank_id: currQuestion.id, questionnaire_section_id: questionnaire_section.id)
      end
    end

    # Sending a message on success
    render json: { message: "Custom questionnaire created successfully" }
  end

  # Editing a template question
  def edit_question
    @question = QuestionBank.find(params[:id]) # the question in the database
    section_id = params[:section_id] # the id of the question's section

    # The question's questionnaire section
    @questionnaire_section = QuestionnaireSection.where(id: section_id).first
    # All questions in the target question's section
    section_questions = SectionQuestion.where(questionnaire_section_id: @questionnaire_section.id)

    # Traversing all the section's questions
    section_questions.each_with_index do |sq, index|
      # Finding what index in the section the question is
      if (sq.question_bank_id == @question.id)
        # Adding 1 since HTML ordered lists are 1-indexed
        @question_id = index + 1
      end
    end

    render "edit_question", layout: false
  end

  # Editing a custom question
  def edit_new_question
    @question_text = params[:question_text] # the question's text content
    question_order_id = params[:id] # the index of the question in the section
    questionnaire_section_id = params[:questionnaire_section_id] # the question's section id
    
    # Getting the question's section
    @section = QuestionnaireSection.where(id: questionnaire_section_id).first
    # The question's order in the ordered list, accounting for 1-indexing of HTML ordered list items
    @new_question_id = question_order_id.to_i + 1
    # Creating the question
    @question = QuestionBank.create(question_text: @question_text)

    render "edit_new_question", layout: false
  end

  # Updating the page layout when a template questionnaire is selected
  def update_questionnaire_layout
    selected_questionnaire_name = params[:questionnaire_type] # the same of the selected questionnaire
    # Calling a helper method to build the layout
    sections = build_questionnaire_sections(selected_questionnaire_name)

    # Passing the questionnaire layout (sections and questions) to the frontend
    render json: { sections: sections }
  end

  # Editing a section's name
  def edit_section
    # Getting the section information
    @question_section = QuestionnaireSection.where(id: params[:id]).first
    @section_with_question_ids = SectionQuestion.where(questionnaire_section_id: @question_section.id)
    @section = @section_with_question_ids.first

    render "edit_section", layout: false
  end

  # Adding a custom question
  def add_question
    # Retrieving the section's order and name
    @section_order = params[:section_order]
    @section_name = params[:section_name] 
    # Retrieving the order of the question in the section
    @list_index = params[:list_index]
    # Retrieving the question's section id
    @questionnaire_section_id = params[:questionnaire_section_id]
    # Creating the question
    @question = QuestionBank.new

    render "add_question", layout: false
  end

  # Adding a question from an existing questionnaire
  def add_question_bank_question
    # Retrieving the section's order and name
    @section_order = params[:section_order]
    @section_name = params[:section_name]
    # Retrieving the order of the question in the section
    @list_index = params[:list_index]
    # Retrieving the question's section id
    @questionnaire_section_id = params[:questionnaire_section_id]
    # Creating the question
    @question = QuestionBank.new
  end

  # Retrieving a questionnaire's sections and questions
  def get_questionnaire_questions
    questionnaire_type = params[:questionnaire_type] # the name of the questionnaire selected
    # Calling a helper method to get the questionnaire's sections and questions
    @sections = build_questionnaire_sections(questionnaire_type)
    
    # Passing the questionnaire layout (sections and questions) to the frontend
    render json: { sections: @sections }
  end

  private

    # Retrieving all custom questionnaires
    def get_questionnaires
      @questionnaires = CustomQuestionnaire.all
    end

    # Building a questionnaire's sections and questions as an array of JSONs
    # Takes a questionnaire name as input
    # Returns the structured sections and questions of the questionnaire
    # Returns [] if the questionnaire name is invalid or not found
    def build_questionnaire_sections(questionnaire_name)
      # Getting the selected questionnaire's data
      selected_questionnaire = CustomQuestionnaire.where(name: questionnaire_name).first
      questionnaire_id = selected_questionnaire.id
      # Joining SectionQuestions and QuestionBank on question_bank_id
      section_questions = QuestionBank
        .joins("LEFT OUTER JOIN section_questions ON section_questions.question_bank_id = question_banks.id")
        .select("question_banks.*, section_questions.questionnaire_section_id")
      questionnaire_sections = QuestionnaireSection.where(custom_questionnaire_id: questionnaire_id)

      if (selected_questionnaire) # checking if null
        # Mapping over the sections with indexes
        sections_data = questionnaire_sections.each_with_index.map do |questionnaire_section, index| 
          # Selecting only the section's questions that have the questionnaire section's id
          section_qs = section_questions.select { |sq| sq.questionnaire_section_id == questionnaire_section.id }
        
          # Creating the JSON object
          {
            id: questionnaire_section.section_order, # the order of the section in the questionnaire
            questionnaire_section_id: questionnaire_section.id,
            name: questionnaire_section.name,
            edit_section_path: edit_section_path(questionnaire_section), # the path for editing the section, passing in the section
            questions: section_qs.map do |sq| # mapping over the questions
              {
                question_text: sq.question_text,
                edit_question_path: edit_question_path(sq) # the path for editing the question, passing in the question
              }
            end
          }
        end

        # Returning the structured sections and questions
        return sections_data
      else
        return []
      end
    end

    # Only allowing a list of trusted parameters through
    def questionnaire_params
      params.permit(:custom_questionnaire).permit(:name)
    end
end
class QuestionnairesController < ApplicationController
  before_action :get_questionnaires, only: [:new, :create, :edit, :add_question_bank_question]
  before_action :authenticate_user!

  def new
    @custom_questionnaire = CustomQuestionnaire.new
    @sections = @custom_questionnaire.questionnaire_sections.build
    
    # puts "Custom questionnaire: #{@custom_questionnaire[0]}"
    # puts "Sections: #{@custom_questionnaire[0]}"
    # @question_bank = QuestionBank.new()
  end

  def create
    @custom_questionnaire = CustomQuestionnaire.new(custom_questionnaire_params)
    
    if params[:questionnaire_sections]
      params[:questionnaire_sections].each do |section_params|
        @custom_questionnaire.questionnaire_sections.create!(section_params.permit(:name))
      end
    end
    
  end

  def edit_question
    @question = QuestionBank.find(params[:id])
    section_linker = SectionQuestion.where(question_bank_id: @question.id).first
    @questionnaire_section = QuestionnaireSection.where(id: section_linker.questionnaire_section_id).first
    first_section_question = SectionQuestion.where(questionnaire_section_id: @questionnaire_section.id).first
    target_section_question = SectionQuestion.where(question_bank_id: @question.id).first
    @question_id = target_section_question.question_bank_id - first_section_question.question_bank_id + 1
    
    render "edit_question", layout: "application"
  end

  def edit_new_question
    @question_text = params[:question_text]
    question_order_id = params[:id]
    section_order = params[:section_order]
    questionnaire_section_id = params[:questionnaire_section_id]
    
    @section = QuestionnaireSection.where(id: questionnaire_section_id).first
    @new_question_id = question_order_id.to_i + 1 # accounting for 1-indexing of list items
    @question = QuestionBank.new(question_text: @question_text)


    puts "question_order_id, #{question_order_id}"
    puts "@new_question_id, #{@new_question_id}"
    render "edit_new_question", layout: "application"
  end

  def update_questionnaire_layout
    selected_questionnaire_name = params[:questionnaire_type]
    sections = build_questionnaire_sections(selected_questionnaire_name)

    render json: { sections: sections }
  end

  def edit_section
    @question_section = QuestionnaireSection.where(id: params[:id]).first
    @section_with_question_ids = SectionQuestion.where(questionnaire_section_id: @question_section.id)
    @section = @section_with_question_ids.first

    render "edit_section", layout: "application"
  end

  def add_question
    @section_order = params[:section_order]
    @section_name = params[:section_name]
    @list_index = params[:list_index]
    @questionnaire_section_id = params[:questionnaire_section_id]
    @question = QuestionBank.new

    render "add_question", layout: "application"
  end

  def add_question_bank_question
    @section_order = params[:section_order]
    @section_name = params[:section_name]
    @list_index = params[:list_index]
    @questionnaire_section_id = params[:questionnaire_section_id]
    @question = QuestionBank.new
  end

  def get_questionnaire_questions
    puts "get_questionnaire_questions"
    questionnaire_template = params[:questionnaire_type]
    @sections = build_questionnaire_sections(questionnaire_template)
    
    render json: { sections: @sections }
  end

  def update_modal_layout
    puts "UPDATE MODAL LAYOUT"
    render json: { message: "Changed template" }
  end

  def save_questionnaire
    render json: { message: "Saved Questionnaire" }
  end

  private

    def get_questionnaires
      @questionnaires = CustomQuestionnaire.all
    end

    def build_questionnaire_sections(questionnaire_name)
      selected_questionnaire = CustomQuestionnaire.where(name: questionnaire_name).first
      questionnaire_id = selected_questionnaire.id
      section_questions = QuestionBank
        .joins("LEFT OUTER JOIN section_questions ON section_questions.question_bank_id = question_banks.id")
        .select("question_banks.*, section_questions.questionnaire_section_id")
      questionnaire_sections = QuestionnaireSection.where(custom_questionnaire_id: questionnaire_id)

      if selected_questionnaire
        sections_data = questionnaire_sections.each_with_index.map do |questionnaire_section, index| 
          section_qs = section_questions.select { |sq| sq.questionnaire_section_id == questionnaire_section.id }
        
          {
            id: questionnaire_section.section_order,
            questionnaire_section_id: questionnaire_section.id,
            name: questionnaire_section.name,
            edit_section_path: edit_section_path(questionnaire_section),
            questions: section_qs.map do |sq|
              {
                question_text: sq.question_text,
                edit_question_path: edit_question_path(sq)
              }
            end
          }
        end
        return sections_data
      else
        return []
      end
    end

    # Only allow a list of trusted parameters through
    def questionnaire_params
      params.permit(:custom_questionnaire).permit(:name, questionnaire_sections_attributes: [:name])
    end
end
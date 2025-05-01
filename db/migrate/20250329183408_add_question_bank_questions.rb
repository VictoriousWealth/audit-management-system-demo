class AddQuestionBankQuestions < ActiveRecord::Migration[7.0]
  def up
    add_YCD_Supplier_Approval_Guidance_Pre_Qualification_Questionnaire
  end
  
  # Questions up to page 16 of: YCD - Supplier Approval Guidance version 3 AUDIT QUESTIONS DETAILED
  def add_YCD_Supplier_Approval_Guidance_Pre_Qualification_Questionnaire
    # Creating questions for the question bank
    questions = [# Section 1
      { question_text: "Are you licensed by the MHRA or equivalent?", category: "Registration" },
      { question_text: "Give details of other company quality systems (e.g. ISO 9000).", category: "Registration" },
      { question_text: "Please give details of staff training  programme.", category: "Registration" },
      { question_text: "Will you supply an original Certificate of Analysis (or photocopies of the original) for  each batch of material supplied?", category: "Certificate of Analysis" },
      { question_text: "What formal policy do you have for dealing with customers and for dealing with complaints?", category: "Complaints/Customer Relations" },
      { question_text: "Please give details of the suppliers  you have audited, if necessary on a  supplementary page. What percentage of the total does this  represent.", category: "Sources" },
      { question_text: "What checks are made on materials before they are received  into stock?", category: "Receipt and Warehousing" },
      { question_text: "What steps are taken to ensure that  materials are adequately segregated, e.g. materials received,  bonded, rejected or returned?", category: "Receipt and Warehousing" },
      { question_text: "Is the environment in the warehouse controlled and monitored for temperature and  humidity? Please give details. ", category: "Receipt and Warehousing" },
      { question_text: "Do you have a separate store for  materials received and returned  goods", category: "Receipt and Warehousing" },
      { question_text: "Are systems in place to ensure  correct goods are supplied? Please give details.", category: "Receipt and Warehousing" },
      { question_text: "How do you transport your materials to your customers?", category: "Labelling and Transport" },
      { question_text: "Are procedures in place to ensure  product is labelled correctly and  complies with e.g. COSHH Regulations? Please give details.", category: "Labelling and Transport" },
      { question_text: "What is your standard delivery  time from receipt of order.", category: "Labelling and Transport" },
      { question_text: "Do you have a batch numbering  system in place?", category: "Labelling and Transport" },
      # Section 2
      { question_text: "Into what type of container do you  pack your materials?", category: "Packaging" },
      { question_text: "Are materials packed/produced in  a controlled environment? Please give details.", category: "Packaging" },
      { question_text: "Do you have a detailed line clearance procedure. If no, please  give details of how this is controlled.", category: "Packaging" },
      { question_text: "Are all products supplied tested to  a documented specification. Does  this include chemical tests. If so, give details.", category: "Quality Assurance/Quality Control" },
      { question_text: "Are copies of specifications available?", category: "" },
      { question_text: "Do you keep reference samples of  materials where appropriate? ", category: "Quality Assurance/Quality Control" },
      { question_text: "Do you have laboratory facilities?", category: "Quality Assurance/Quality Control" },
      { question_text: "If no do you have access to laboratory facilities.", category: "Quality Assurance/Quality Control" },
      { question_text: "Please give details of laboratory  facilities.", category: "Quality Assurance/Quality Control" }
    ]

    # Populating fields for all questions
    updated_questions = []

    questions.each_with_index do |q, i|
      updated_question = { id: i + 1, question_text: q[:question_text], category: q[:category], created_at: Time.now, updated_at: Time.now }
      updated_questions.push(updated_question)
    end

    # Adding all created questions
    QuestionBank.insert_all(updated_questions)
    
    # Creating a user
    user = { email: "jdoe@sheffield.ac.uk", first_name: "Jane", last_name: "Doe", password: "Password123", role: 0, created_at: Time.now, updated_at: Time.now }
    User.create!(user)
    
    # Creating a custom questionnaire
    custom_questionnaire = { name: "YCD - Supplier Approval Guidance Pre Qualification Questionnaire", time_of_creation: Time.now, created_at: Time.now, updated_at: Time.now, user: User.last }
    CustomQuestionnaire.create!(custom_questionnaire)
    
    # Finding the custom questionnaire
    cq = CustomQuestionnaire.find_by(name: "YCD - Supplier Approval Guidance Pre Qualification Questionnaire")
    cq_id = cq[:id]
  
    questionnaire_sections = [
      { name: "Section 1", section_order: 1, created_at: Time.now, updated_at: Time.now, custom_questionnaire_id: cq_id },
      { name: "Section 2", section_order: 2, created_at: Time.now, updated_at: Time.now, custom_questionnaire_id: cq_id }
    ]

    # Adding the questionnaire_sections
    QuestionnaireSection.insert_all(questionnaire_sections)

    # Populating fields for section questions
    section_questions = []

    questions.each_with_index do |q, i|
      if i < 15 # Section 1 ends at id 15
        qs = QuestionnaireSection.find_by(name: "Section 1", custom_questionnaire_id: cq_id)
      else
        qs = QuestionnaireSection.find_by(name: "Section 2", custom_questionnaire_id: cq_id)
      end
      
      question = QuestionBank.find_by(question_text: q[:question_text])
      qb_id = question[:id]
      qs_id = qs[:id]

      section_question = { id: i + 1, created_at: Time.now, updated_at: Time.now, question_bank_id: qb_id, questionnaire_section_id: qs_id }
      section_questions.push(section_question)
    end

    # Adding all created section questions
    SectionQuestion.insert_all(section_questions)
  end
end

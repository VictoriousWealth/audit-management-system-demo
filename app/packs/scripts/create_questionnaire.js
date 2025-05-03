document.addEventListener('DOMContentLoaded', function() {
    // Getting the elements needed for the Create Questionnaire page
    let templateRadBtn = document.getElementById('option-template').children[1];
    let customRadBtn = document.getElementById('option-custom').children[1];
    let templateContent = document.getElementById('template-content');
    let customContent = document.getElementById('custom-content');
    let questionnaireDropdown = document.getElementById('template-content').children[1];
    let accordionContainer = document.getElementById('section-accordion-container');

    if (templateRadBtn) {
        // Toggling template questionnaire content
        templateRadBtn.addEventListener('change', function() {
            if (templateRadBtn.checked) {
                templateContent.style.display = 'block';
                customContent.style.display = 'none';
            }
        })
    }
    
    if (customRadBtn) {
         // Toggling custom questionnaire content
        customRadBtn.addEventListener('change', function() {
            if (customRadBtn.checked) {
                templateContent.style.display = 'none';
                customContent.style.display = 'block';
            }
        })
    }

    if (questionnaireDropdown || questionnaireDropdown != " ") {
        // Getting the selected template questionnaire questions and sections
        questionnaireDropdown.addEventListener('change', function() {
            let selectedValue = questionnaireDropdown.value;

            if (selectedValue.trim() == "") {
                // Clearing content in the accordion
                accordionContainer.innerHTML = "";
            }
    
            // Fetching data from the controller to update the page layout
            fetch('/update_questionnaire_layout', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                },
                body: JSON.stringify({ questionnaire_type: selectedValue })
            })
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    console.error("Error:", data.error);
                    return;
                }
    
                // Clearing content in the accordion
                accordionContainer.innerHTML = "";
    
                data.sections.forEach((section, index) => {
                    // Updating the accordion content with the questionnaire information
                    let accordionItem = document.createElement("div");
                    accordionItem.className = `accordion-item-${index}`;
                    accordionItem.innerHTML = `
                    <div class="section-heading-container">
                        <h3 class="questionnaire-title questionnaire-sub-heading" id="section-name-${index}">${section.name}</h3>
                        <a href="${section.edit_section_path}" data-turbo-frame="modal" class="edit-question-btn">Edit</a>
                    </div>
                    <div class="section-accordion-container">
                        <button class="accordion-button-underline accordion-button collapsed d-flex justify-content-between align-items-center" 
                                type="button" data-bs-toggle="collapse" data-bs-target="#collapse${index}" 
                                aria-expanded="false" aria-controls="collapse${index}">
                            <div class="play-arrow-icon">
                                <i class="bi bi-play-fill"></i>
                            </div>
                        </button>
                        <div id="collapse${index}" class="collapse">
                            <div data-controller="modals" class="modal-controller template-questionnaire-inner-container">
                                <a data-action="modals#removeSectionQuestions" class="remove-all-questions-btn">Remove All Questions</a>
                                <ol id="question-list-${index}">
                                    ${section.questions.map((q, i) => `
                                    <li id="list-item-${i}" >
                                        <div class="question-item-wrapper" id="question-wrapper-${i}">
                                            <div class="question-text-container" id="question-text-${i}">
                                                ${q.question_text}
                                            </div>
                                            <div class="edit-question-container">
                                                <a href="${q.edit_question_path}?section_id=${section.questionnaire_section_id}" data-turbo-frame="modal" class="edit-question-btn">Edit</a>
                                            </div>
                                        </div>
                                    </li>
                                `).join('')}
                                </ol>
                                <div data-controller="modals" class="modal-controller">
                                    <a class='add-question' id="add-question" data-bs-toggle="collapse" href="#add-question-container-${index}" role="button" aria-expanded="false" aria-controls="collapse">
                                        <i class="bi bi-plus-circle-fill"></i>
                                        Add Question
                                    </a>
                                    <div class="add-question-container collapse" id="add-question-container-${index}" data-section-id='${section.id}' data-questionnaire-section-id='${section.questionnaire_section_id}' data-section-name='${section.name}' data-list-index='${index}'>
                                        <button class="questionnaire-btn add-question-btn" data-action='modals#showAddQuestionBankQuestion' data-add-question-path='_add_question_bank_question'>Insert Question From Question Bank</button>
                                        <button class="questionnaire-btn add-question-btn" data-action='modals#showAddQuestion' data-add-question-path='_add_question'>Add Custom Question</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    `;
                    accordionContainer.appendChild(accordionItem);
                });
            })
            .catch(error => console.error("Error:", error));
        });
    }

    if (accordionContainer) {
        // Changing the add question icon when clicked
        accordionContainer.addEventListener('click', function (e) {
            if (e.target.closest('.add-question')) {
                const tag = e.target.closest('.add-question').querySelector("i");
                tag.classList.toggle("bi-play-circle-fill");
                tag.classList.toggle("bi-plus-circle-fill");
            }
        });
    }
    
    // Opening the modal
    openModal();
});

// Opening the modal after the turbo frame has loaded 
// and when the clicked element is a modal
function openModal() {
    document.addEventListener("turbo:frame-load", function(e) {
        if (e.target.id === "modal") {
            // Opening the modal and preventing page scroll
            document.body.classList.add("modal-open");
        }
    });
}
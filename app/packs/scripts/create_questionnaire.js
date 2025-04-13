document.addEventListener('DOMContentLoaded', function() {
    let templateRadBtn = document.getElementById('option-template').children[1];
    let customRadBtn = document.getElementById('option-custom').children[1];
    let templateContent = document.getElementById('template-content');
    let customContent = document.getElementById('custom-content');
    let questionnaireDropdown = document.getElementById('template-content').children[1];
    let accordionContainer = document.getElementById('section-accordion-container');
    let addQuestionBtn = document.getElementById('add-question');

    templateRadBtn.addEventListener('change', function() {
        if (templateRadBtn.checked) {
            templateContent.style.display = 'block';
            customContent.style.display = 'none';
        }
    })

    customRadBtn.addEventListener('change', function() {
        if (customRadBtn.checked) {
            templateContent.style.display = 'none';
            customContent.style.display = 'block';
        }
    })

    questionnaireDropdown.addEventListener('change', function() {
        let selectedValue = questionnaireDropdown.value;

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

            // Clear accordionContainer content
            accordionContainer.innerHTML = "";

            // Dynamically add new sections
            data.sections.forEach((section, index) => {
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
                        <div data-controller="modals" class="template-questionnaire-inner-container">
                            <a data-action="modals#removeSectionQuestions" class="remove-all-questions-btn">Remove All Questions</a>
                            <ol id="question-list-${index}">
                                ${section.questions.map((q, i) => `
                                <li id="list-item-${i}" >
                                    <div class="question-item-wrapper" id="question-wrapper-${i}">
                                        <div class="question-text-container" id="question-text-${i}">
                                            ${q.question_text}
                                        </div>
                                        <div class="edit-question-container">
                                            <a href="${q.edit_question_path}" data-turbo-frame="modal" class="edit-question-btn">Edit</a>
                                        </div>
                                    </div>
                                </li>
                            `).join('')}
                            </ol>
                            <div data-controller="modals">
                                <a class='add-question' id="add-question" data-bs-toggle="collapse" href="#add-question-container" role="button" aria-expanded="false" aria-controls="collapse">
                                    <i class="bi bi-plus-circle-fill"></i>
                                    Add Question
                                </a>
                                <div class="add-question-container collapse" id="add-question-container">
                                    <button class="questionnaire-btn add-question-btn">Insert Question From Question Bank</button>
                                    <button class="questionnaire-btn add-question-btn" data-action='modals#showAddQuestion' data-add-question-path='_add_question' data-section-id='${section.id}' data-questionnaire-section-id='${section.questionnaire_section_id}' data-section-name='${section.name}' data-list-index='${index}'>Add Custom Question</button>
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


    accordionContainer.addEventListener('click', function (e) {
        if (e.target.closest('.add-question')) {
            const tag = e.target.closest('.add-question').querySelector("i");
            tag.classList.toggle("bi-play-circle-fill");
            tag.classList.toggle("bi-plus-circle-fill");
        }
    });

});
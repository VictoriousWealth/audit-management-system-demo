import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    close(e) {
        // Preventing refresh
        e.preventDefault();
    
        const modal = document.getElementById("modal");
        modal.innerHTML = "";
        modal.removeAttribute("src");
        modal.removeAttribute("complete");
    
        document.body.classList.remove("modal-open");
    }

    saveQuestionEdit(e) {
        // Preventing refresh
        e.preventDefault();

        let qInput = document.getElementById("question_bank_question_text");
        let modal = document.getElementsByClassName("modal")[0];
        const updatedQ = qInput.value;

        // Finding the question's element on the main questionnaire form
        const qId = modal.dataset.modalsQuestionIdValue;
        const sectionValue = e.target.getAttribute("modal_section_value");

        const accordionItem = document.getElementsByClassName(`accordion-item-${sectionValue - 1}`)[0];
        const qTextElement = accordionItem.querySelector(`#question-text-${qId - 1}`);

        // Updating the question text on the main page
        qTextElement.textContent = updatedQ;

        // Closing the modal
        this.close(e);
    }

    removeQuestion(e) {
        // Preventing refresh
        e.preventDefault();

        let modal = document.getElementsByClassName("modal")[0];

        // Finding the question's element on the main questionnaire form
        const qId = modal.dataset.modalsQuestionIdValue;
        const sectionValue = e.target.getAttribute("data-modal-section-value");

        const accordionItem = document.getElementsByClassName(`accordion-item-${sectionValue - 1}`)[0];
        const listItem = accordionItem.querySelector(`#list-item-${qId - 1}`);
        
        const confirmation = window.confirm("Are you sure you want to remove this question?");
        
        if (confirmation) {
            listItem.remove();
        }
        
        this.close(e);
    }

    saveSectionEdit(e) {
        // Preventing refresh
        e.preventDefault();


        let sectionInput = document.getElementById("questionnaire_section_name");
        let modal = document.getElementsByClassName("modal")[0];
        const updatedInput = sectionInput.value;

        // Finding the section's element on the main questionnaire form
        const sectionId = modal.dataset.modalsSectionIdValue;
        const sectionTextElement = document.querySelector(`#section-name-${sectionId - 1}`);
        
        // Updating the section name on the main page
        sectionTextElement.textContent = updatedInput;

        // Closing the modal
        this.close(e);
    }

    removeSection(e) {
        // Preventing refresh
        e.preventDefault();

        let modal = document.getElementsByClassName("modal")[0];

        // Finding the question's element on the main questionnaire form
        const sectionId = modal.dataset.modalsSectionIdValue;
        const accordionItem = document.getElementsByClassName(`accordion-item-${sectionId - 1}`)[0]
        const children = accordionItem.children;

        const confirmation = window.confirm("Are you sure you want to remove this entire section?");
        
        if (confirmation) {
            accordionItem.remove(children);
        }
        
        // Closing the modal
        this.close(e);
    }

    removeSectionQuestions(e) {
        // Preventing refresh
        e.preventDefault();

        const orderedlistItem = e.target.nextElementSibling;

        const confirmation = window.confirm("Are you sure you want to remove all of this section's questions?");
        
        if (confirmation) {
            while (orderedlistItem.firstChild) {
                orderedlistItem.removeChild(orderedlistItem.lastChild);
            }
        }
    }

    showAddQuestion(e) {
        // Preventing refresh
        e.preventDefault();

        document.body.classList.add("modal-open");

        const parentContainer = e.target.closest(".add-question-container");

        const addQuestionPath = e.target.getAttribute("data-add-question-path");
        const sectionId = parentContainer.getAttribute("data-section-id");
        const sectionName = parentContainer.getAttribute("data-section-name");
        const questionnaireSectionId = parentContainer.getAttribute("data-questionnaire-section-id");
        const listIndex = parentContainer.getAttribute("data-list-index");

        // Sending data to the controller
        fetch(addQuestionPath, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify({ section_order: sectionId, section_name: sectionName, questionnaire_section_id: questionnaireSectionId, list_index: listIndex })
        })
        .then(response => {
            if (!response.ok) { throw response };
            return response.text();
        })
        .then(html => {
            const modal = document.getElementById("modal");
            const parser = new DOMParser();
            const doc = parser.parseFromString(html, "text/html");
            const modalContent = doc.querySelector("#modal").innerHTML;
            modal.innerHTML = modalContent;
        })
        .catch(error => {
            console.error("Error loading modal content:", error);
        });
    }

    addQuestion(e) {
        e.preventDefault();

        const questionInput = document.getElementById("question_bank_question_text");
        const modal = document.getElementsByClassName("modal")[0];
        const updatedQ = questionInput.value;
        const listIndex = modal.dataset.modalsListIndexValue;
        const listParent = document.getElementById(`question-list-${listIndex}`);
        const newIndex = listParent.children.length;
        const sectionName = document.querySelector(".questionnaire-subtitle").textContent;
        const questionnaireSectionId = modal.dataset.modalQuestionnaireSectionId;

        const entry = document.createElement('li');
        entry.id = `list-item-${newIndex}`;
        entry.innerHTML = `
        <div class="question-item-wrapper" id="question-wrapper-${newIndex}">
            <div class="question-text-container" id="question-text-${newIndex}">
                ${updatedQ}
            </div>
            <div class="edit-question-container">
                <a href='#' data-action="modals#showEditNewQuestion" data-turbo-frame="modal" data-question-text="${updatedQ}" data-section-name='${sectionName}' data-questionnaire-section-id='${questionnaireSectionId}' data-index='${newIndex}' class="edit-question-btn">Edit</a>
            </div>
        </div>
        `;

        listParent.appendChild(entry);

        // Closing the modal
        this.close(e);
    }

    showEditNewQuestion(e) {
        e.preventDefault();

        document.body.classList.add("modal-open");

        const questionText = e.target.getAttribute("data-question-text");
        const index = e.target.getAttribute("data-index");
        const questionnaireSectionId = e.target.getAttribute("data-questionnaire-section-id");

        // Prepare the request
        const url = "/questionnaire/_edit_new_question";

        // Send the fetch request
        fetch(url, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ question_text: questionText, id: index, questionnaire_section_id: questionnaireSectionId })
        })
        .then(response => {
            if (!response.ok) { throw response };
            return response.text();
        })
        .then(html => {
            const modal = document.getElementById("modal");
            const parser = new DOMParser();
            const doc = parser.parseFromString(html, "text/html");
            const modalContent = doc.querySelector("#modal").innerHTML;
            modal.innerHTML = modalContent;
        })
        .catch(error => {
            console.error("Error showing question modal:", error);
        });
    }

    showAddQuestionBankQuestion(e) {
        e.preventDefault();

        document.body.classList.add("modal-open");

        const path = e.target.getAttribute("data-add-question-path");
        const parentContainer = e.target.closest(".add-question-container");

        const sectionId = parentContainer.getAttribute("data-section-id");
        const sectionName = parentContainer.getAttribute("data-section-name");
        const questionnaireSectionId = parentContainer.getAttribute("data-questionnaire-section-id");
        const listIndex = parentContainer.getAttribute("data-list-index");

         // Sending data to the controller
         fetch(path, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
            },
            body: JSON.stringify({ section_order: sectionId, section_name: sectionName, questionnaire_section_id: questionnaireSectionId, list_index: listIndex })
        })
        .then(response => {
            if (!response.ok) { throw response };
            return response.text();
        })
        .then(html => {
            const modal = document.getElementById("modal");
            const parser = new DOMParser();
            const doc = parser.parseFromString(html, "text/html");
            const modalContent = doc.querySelector("#modal").innerHTML;
            modal.innerHTML = modalContent;
        })
        .catch(error => {
            console.error("Error loading modal content:", error);
        });
    }

    getTemplateQuestions(e) {
        e.preventDefault();

        const templateSelect = document.getElementById('select-template').children[1];
        
        const selectedValue = templateSelect.value;

        fetch('/get_questionnaire_questions', {
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

            const questionsBox = document.getElementById('questions-box');
            questionsBox.innerHTML = "";
            data.sections.forEach((section, index) => {
                let sectionChunk = document.createElement("div");
                sectionChunk.className = `section-chunk-${index}`;
                sectionChunk.innerHTML = `
                <div class="section-title-container">
                    <h5 class="question-box-section-title">${section.name}</h5>
                </div>
                <ul id="question-box-list-${index}" data-section-order="${index}" data-section-name="${section.name}">
                    ${section.questions.map((q, i) => `
                    <li id="box-list-item-${i}">
                        <div class="question-box-item-wrapper" id="question-box-wrapper-${i}">
                        <input type="checkbox" name="question-box-text[]" class="question-box-text-input" id="question-box-text-${index}-${i}" value="${q.id}">
                        <label class="question-text-label" for="question-box-text-${index}-${i}">
                            ${q.question_text}
                        </label>
                        </div>
                    </li>
                `).join('')}
                </ul>
                `;
                questionsBox.appendChild(sectionChunk);
            });
        })
        .catch(error => console.error("Error:", error));
    }

    restoreTemplateQuestions(data, query) {
        const questionsBox = document.getElementById('questions-box');
        questionsBox.innerHTML = "";
    
        try {
            data.sections.forEach((section, index) => {
                const filteredQuestions = section.questions.filter((q) =>
                    q.question_text.toLowerCase().includes(query.toLowerCase())
                );
    
                // Skip empty sections
                if (filteredQuestions.length === 0) {
                    return;
                }
    
                let sectionChunk = document.createElement("div");
                sectionChunk.className = `section-chunk-${index}`;
                sectionChunk.innerHTML = `
                    <div class="section-title-container">
                        <h5 class="question-box-section-title">${section.name}</h5>
                    </div>
                    <ul id="question-box-list-${index}" data-section-order="${index}" data-section-name="${section.name}">
                        ${filteredQuestions.map((q, i) => `
                        <li id="box-list-item-${i}">
                            <div class="question-box-item-wrapper" id="question-box-wrapper-${i}">
                                <input type="checkbox" name="question-box-text[]" class="question-box-text-input" id="question-box-text-${index}-${i}" value="${q.id}">
                                <label class="question-text-label" for="question-box-text-${index}-${i}">
                                    ${q.question_text}
                                </label>
                            </div>
                        </li>
                        `).join('')}
                    </ul>
                `;
                questionsBox.appendChild(sectionChunk);
            });
        } catch (e) {
            console.log("Error: cannot update questions");
            console.log(e);
        }
    }

    filterQuestions(e) {
        e.preventDefault();
    
        const query = e.target.value.toLowerCase();
        const templateSelect = document.getElementById('select-template').children[1];
        const selectedValue = templateSelect.value;
    
        fetch('/get_questionnaire_questions', {
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
    
            this.restoreTemplateQuestions(data, query);
        })
        .catch(error => console.error("Error:", error));
    }

    addQuestionBankQuestions(e) {
        e.preventDefault();

        const checkedBoxes = document.querySelectorAll('input[name^=question-box-text]:checked');
        console.log(checkedBoxes);

        e.preventDefault();

        const modal = document.getElementsByClassName("modal")[0];
        const listIndex = modal.dataset.modalsListIndexValue;
        const listParent = document.getElementById(`question-list-${listIndex}`);
        const newIndex = listParent.children.length;
        const sectionName = document.querySelector(".questionnaire-subtitle").textContent;
        const questionnaireSectionId = modal.dataset.modalQuestionnaireSectionId;

        checkedBoxes.forEach((checkedItem) => {
            const question = checkedItem.nextElementSibling.textContent.trim();
            const entry = document.createElement('li');
            entry.id = `list-item-${newIndex}`;
            entry.innerHTML = `
            <div class="question-item-wrapper" id="question-wrapper-${newIndex}">
                <div class="question-text-container" id="question-text-${newIndex}">
                    ${question}
                </div>
                <div class="edit-question-container">
                    <a href='#' data-action="modals#showEditNewQuestion" data-turbo-frame="modal" data-question-text="${question}" data-section-name='${sectionName}' data-questionnaire-section-id='${questionnaireSectionId}' data-index='${newIndex}' class="edit-question-btn">Edit</a>
                </div>
            </div>
            `;

            listParent.appendChild(entry);
        })

        // Closing the modal
        this.close(e);
    }
}
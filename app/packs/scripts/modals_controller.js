import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
    // Closing a modal
    close(e) {
        // Preventing refresh
        e.preventDefault();
    
        // Removing modal attributes to close the modal
        const modal = document.getElementById("modal");
        modal.innerHTML = "";
        modal.removeAttribute("src");
        modal.removeAttribute("complete");
        document.body.classList.remove("modal-open");
    }

    // Saving a question edit to the main page
    saveQuestionEdit(e) {
        // Preventing refresh
        e.preventDefault();

        // Getting elements for entering a custom question and the modal
        let qInput = document.getElementById("question_bank_question_text");
        let modal = document.getElementsByClassName("modal")[0];
        const updatedQ = qInput.value;

        // Finding the question's element on the main questionnaire form
        const qId = modal.dataset.modalsQuestionIdValue;
        const sectionValue = e.target.getAttribute("modal_section_value");

        // Getting elements for updating the main page
        const accordionItem = document.getElementsByClassName(`accordion-item-${sectionValue - 1}`)[0];
        const qTextElement = accordionItem.querySelector(`#question-text-${qId - 1}`);

        // Updating the question text on the main page
        qTextElement.textContent = updatedQ;

        // Closing the modal
        this.close(e);
    }

    // Removing an already existing question from the main page
    removeQuestion(e) {
        // Preventing refresh
        e.preventDefault();

        // Getting the modal element
        let modal = document.getElementsByClassName("modal")[0];

        // Finding the question's element on the main questionnaire form
        const qId = modal.dataset.modalsQuestionIdValue;
        const sectionValue = e.target.getAttribute("data-modal-section-value");
        const accordionItem = document.getElementsByClassName(`accordion-item-${sectionValue - 1}`)[0];
        const listItem = accordionItem.querySelector(`#list-item-${qId - 1}`);
        
        // Flashing a confirmation message
        const confirmation = window.confirm("Are you sure you want to remove this question?");
        
        if (confirmation) {
            listItem.remove();
        }
        
        // Closing the modal
        this.close(e);
    }

    // Saving an edit to a particular section
    saveSectionEdit(e) {
        // Preventing refresh
        e.preventDefault();

        // Getting the elements for input on the modal form
        let sectionInput = document.getElementById("questionnaire_section_name");
        let modal = document.getElementsByClassName("modal")[0];
        const updatedInput = sectionInput.value;

        // Finding the section's element on the main questionnaire form
        const sectionId = modal.dataset.modalsSectionIdValue;
        const sectionTextElement = document.querySelector(`#section-name-${sectionId - 1}`);
        
        console.log(updatedInput);
        console.log(sectionId);
        console.log(sectionTextElement);

        // Updating the section name on the main page
        sectionTextElement.textContent = updatedInput;

        // Closing the modal
        this.close(e);
    }

    // Removing an entire section with its question
    removeSection(e) {
        // Preventing refresh
        e.preventDefault();

        // Getting the modal element
        let modal = document.getElementsByClassName("modal")[0];

        // Finding the question's element on the main questionnaire form
        const sectionId = modal.dataset.modalsSectionIdValue;
        const accordionItem = document.getElementsByClassName(`accordion-item-${sectionId - 1}`)[0]
        const children = accordionItem.children;

        // Flashing a confirmation message
        const confirmation = window.confirm("Are you sure you want to remove this entire section?");
        
        if (confirmation) {
            accordionItem.remove(children);
        }
        
        // Closing the modal
        this.close(e);
    }

    // Removing just a section's questions (without removing the section itself)
    removeSectionQuestions(e) {
        // Preventing refresh
        e.preventDefault();

        // Getting the ol element for the target section
        const orderedlistItem = e.target.nextElementSibling;

        // Flashing a confirmation message
        const confirmation = window.confirm("Are you sure you want to remove all of this section's questions?");
        
        if (confirmation) {
            while (orderedlistItem.firstChild) {
                // Removing all list items
                orderedlistItem.removeChild(orderedlistItem.lastChild);
            }
        }
    }

    // Showing the modal for adding a custom question
    showAddQuestion(e) {
        // Preventing refresh
        e.preventDefault();

        // Opening the modal and preventing page scroll
        document.body.classList.add("modal-open");

        // Getting the parent container of the add question button
        const parentContainer = e.target.closest(".add-question-container");

        // Getting information to pass to the controller
        const addQuestionPath = e.target.getAttribute("data-add-question-path");
        const sectionId = parentContainer.getAttribute("data-section-id");
        const sectionName = parentContainer.getAttribute("data-section-name");
        const questionnaireSectionId = parentContainer.getAttribute("data-questionnaire-section-id");
        const listIndex = parentContainer.getAttribute("data-list-index");

        // Sending data to the controller as a POST request
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
            // Updating the modal with the content
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

    // Adding the custom question to the page
    addQuestion(e) {
        // Preventing refresh
        e.preventDefault();

        // Getting elements from the modal and main page
        const questionInput = document.getElementById("question_bank_question_text");
        const modal = document.getElementsByClassName("modal")[0];
        const updatedQ = questionInput.value;
        const listIndex = modal.dataset.modalsListIndexValue;
        const listParent = document.getElementById(`question-list-${listIndex}`);
        const newIndex = listParent.children.length;
        const sectionName = document.querySelector(".questionnaire-subtitle").textContent;
        const questionnaireSectionId = modal.dataset.modalQuestionnaireSectionId;

        // Creating the new question entry as a list item
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

    // Showing the edit new question modal
    showEditNewQuestion(e) {
        // Preventing refresh
        e.preventDefault();
        console.log("here");
        // Opening the modal and preventing page scroll
        document.body.classList.add("modal-open");

        // Getting the question information
        const questionText = e.target.getAttribute("data-question-text");
        const index = e.target.getAttribute("data-index");
        const questionnaireSectionId = e.target.getAttribute("data-questionnaire-section-id");

        // Preparing the request
        const url = "/questionnaire/_edit_new_question";

        // Sending the data as a POST request to the controller
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
            // Updating the modal
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

    // Showing the add question bank question modal
    showAddQuestionBankQuestion(e) {
        // Preventing refresh
        e.preventDefault();

        // Opening the modal and preventing page scroll
        document.body.classList.add("modal-open");

        // Getting the route to send the data to the controller
        const path = e.target.getAttribute("data-add-question-path");

        // Getting the parent container of the button
        const parentContainer = e.target.closest(".add-question-container");

        // Getting information for updating the main page
        const sectionId = parentContainer.getAttribute("data-section-id");
        const sectionName = parentContainer.getAttribute("data-section-name");
        const questionnaireSectionId = parentContainer.getAttribute("data-questionnaire-section-id");
        const listIndex = parentContainer.getAttribute("data-list-index");

         // Sending data to the controller in a POST request
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
            // Updating the modal
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

    // Fetching the template questions from the database
    getTemplateQuestions(e) {
        // Preventing refresh
        e.preventDefault();

        // Getting the name of the selected template
        const templateSelect = document.getElementById('select-template').children[1];
        const selectedValue = templateSelect.value;

        // Fetching the selected questionnaire questions using a POST request
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

            // Updating the questions box with the template questions
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

    // Helper function for filtering question bank questions
    restoreTemplateQuestions(data, query) {
        // Clearing the questions box
        const questionsBox = document.getElementById('questions-box');
        questionsBox.innerHTML = "";
    
        try {
            data.sections.forEach((section, index) => {
                // Only including questions that have the query in it
                const filteredQuestions = section.questions.filter((q) =>
                    q.question_text.toLowerCase().includes(query.toLowerCase())
                );
    
                // Skipping empty sections
                if (filteredQuestions.length === 0) {
                    return;
                }
    
                // Updating the questions box using the filtered questions and their sections
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

    // Main function for filtering 
    filterQuestions(e) {
        // Preventing refresh
        e.preventDefault();
    
        // Getting elements for updating the filtering
        const query = e.target.value.toLowerCase();
        const templateSelect = document.getElementById('select-template').children[1];
        const selectedValue = templateSelect.value;

        if (selectedValue.trim() == "") {
            // Clearing the questions box
            const questionsBox = document.getElementById('questions-box');
            console.log(questionsBox)
            questionsBox.innerHTML = "";
        } else {
            // Fetching the data from the selected questionnaire
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

                // Restoring the state of the questions box
                this.restoreTemplateQuestions(data, query);
            })
            .catch(error => console.error("Error:", error));
        }
    }

    // Adding question bank questions to the main page
    addQuestionBankQuestions(e) {
        // Preventing refresh
        e.preventDefault();

        // Getting all selected questions
        const checkedBoxes = document.querySelectorAll('input[name^=question-box-text]:checked');

        // Getting elements for updating the main page
        const modal = document.getElementsByClassName("modal")[0];
        const sectionName = document.querySelector(".questionnaire-subtitle").textContent;
        const questionnaireSectionId = modal.dataset.modalQuestionnaireSectionId;
        const sectionOrder = modal.dataset.modalSectionValue - 1;
        const listParent = document.getElementById(`question-list-${sectionOrder}`);
        let newIndex = listParent.children.length;

        // Updating the main page with the selected questions
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

            listParent.appendChild(entry); // adding the entry to the list
            newIndex++; // incrementing the index
        })

        // Closing the modal
        this.close(e);
    }

    // Parsing the questions and sections to send to the
    // controller for custom questionnaire creation
    create(e) {
        // Preventing refresh
        e.preventDefault();

        const questionnaireTitle = document.getElementById("custom_questionnaire_name").value;
        const templateRadBtn = document.getElementById('option-template').children[1];
        const customRadBtn = document.getElementById('option-custom').children[1];
        const questionnaireDropdownValue = document.getElementById('template-content').children[1].value;

        if (questionnaireTitle.trim() == "") {
            // Showing the title error message if title is empty
            const titleError = document.getElementById("title-error");
            titleError.classList.remove("hide");
            window.scrollTo(0, 0);
        }

        if (!templateRadBtn.checked && !customRadBtn.checked) {
            // Showing the questionnaire type error message if unchecked
            const questionnaireTypeError = document.getElementById("questionnaire-type-error");
            questionnaireTypeError.classList.remove("hide");
            window.scrollTo(0, 0);
        }

        if (questionnaireDropdownValue.trim() == "") {
            // Showing the questionnaire template error message if none selected
            const templateSelectError = document.getElementById("template-select-error");
            templateSelectError.classList.remove("hide");
            window.scrollTo(0, 0);
        }
        
        if (questionnaireTitle.trim() != "" && 
        (templateRadBtn.checked || customRadBtn.checked) &&
        questionnaireDropdownValue.trim() != "") {
            // Getting the questionnaire dropdown element
            let questionnaireDropdown = document.getElementById('template-content').children[1];

            if (questionnaireDropdown) {
                const sections = document.querySelectorAll('[id^=section-name]');

                let data = [];

                sections.forEach((section) => {
                    const sectionOrder = section.id.slice(-1);
                    const sectionName = section.innerText;
                    const questionList = document.querySelector(`#question-list-${sectionOrder}`).children;

                    let sectionItem = {
                        id: Number(sectionOrder) + 1,
                        name: sectionName
                    }

                    let qs = [];

                    for (let listItem of questionList) {
                        const q = listItem.querySelector(".question-text-container").innerText.trim();
                        qs.push(q);
                    }

                    if (qs.length != 0) {
                        sectionItem.questions = qs;
                    }
                    
                    data.push(sectionItem);
                });

                console.log(data)
                
                fetch('/questionnaire', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-Token': document.querySelector('meta[name="csrf-token"]').content
                    },
                    body: JSON.stringify({ data: data, title: questionnaireTitle })
                })
                .then(response => response.json())
                .then(data => {
                    if (data.error) {
                        console.error("Error:", data.error);
                        return;
                    } else {
                        console.log(data.message);
                    }

                    window.alert("Questionnaire created successfully");
                    window.location.href = "/questionnaire/new";
                    
                })
                .catch(error => console.error("Error:", error));
                }
            }
    }
}
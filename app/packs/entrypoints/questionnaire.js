import '../scripts/create_questionnaire';
import "../scripts/modals_controller";
import "@hotwired/turbo-rails";
import { Application } from "@hotwired/stimulus"
import ModalsController from "../scripts/modals_controller"


const application = Application.start()
application.register("modals", ModalsController)
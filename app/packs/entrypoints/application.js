import Rails from "@rails/ujs";
import "bootstrap"
import './styles'
import '../scripts/audit_form';
import '../scripts/iChart'
import '../scripts/iCalendar'

import "../scripts/nav_bar";
import "../scripts/create_audit_closure_letter";

import '../scripts/create_questionnaire';
import "../scripts/modals_controller";
import "@hotwired/turbo-rails";
import { Application } from "@hotwired/stimulus"
import ModalsController from "../scripts/modals_controller"


const application = Application.start()
application.register("modals", ModalsController)
//import "../scripts/show_comapany_field"

Rails.start();

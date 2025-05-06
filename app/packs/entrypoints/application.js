import Rails from "@rails/ujs";
import * as bootstrap from 'bootstrap'
window.bootstrap = bootstrap 
import './styles'
import "../scripts/nav_bar";

import '../scripts/audit_form';
import '../scripts/supporting_documents'
import '../scripts/iChart'
import '../scripts/iCalendar'

import "../scripts/create_audit_closure_letter";

//import "../scripts/show_comapany_field"

Rails.start();

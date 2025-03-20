import Rails from "@rails/ujs";
import './styles'
import 'bootstrap';
import Chartkick from "chartkick"
import Chart from "chart.js/auto"  // 'chart.js' alone may throw issues in newer versions

Chartkick.use(Chart)


Rails.start();
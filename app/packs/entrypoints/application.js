import Rails from "@rails/ujs";
import './styles'
import 'bootstrap';
import Chartkick from "chartkick"
import Chart from "chart.js/auto"  
import ChartDataLabels from 'chartjs-plugin-datalabels'  
Chartkick.options = {
    colors: ["#42CA68", "#F39C12", "#E74C3C", "#8E44AD", "#3498DB"]
};

Chart.register(ChartDataLabels)                            
Chartkick.use(Chart)

Rails.start();
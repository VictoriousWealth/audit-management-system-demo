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

document.addEventListener("DOMContentLoaded", function () {
  function waitForCharts(callback, retries = 10, delay = 100) {
    const pieChart = Chartkick.charts["pieChart"];
    const barChart = Chartkick.charts["barChart"];
    const complianceChart = Chartkick.charts["complianceScoreChart"];


    if (pieChart && barChart && complianceChart) {
      callback(pieChart, barChart, complianceChart);
    } else if (retries > 0) {
      setTimeout(() => waitForCharts(callback, retries - 1, delay), delay);
    } else {
      console.error("Charts not found after waiting.");
    }
  }

  // Move pieDataMap and barDataMap inside the callback
  waitForCharts((pieChart, barChart, complianceChart) => {
    const pieDataMap = {
      day: window.pieChartDataByDay,
      week: window.pieChartDataByWeek,
      month: window.pieChartDataByMonth,
      all: window.pieChartDataAll
    };

    const barDataMap = {
      day: window.barChartDataByDay,
      week: window.barChartDataByWeek,
      month: window.barChartDataByMonth,
      all: window.barChartDataAll
    };

    const complianceDataMap = {
      day: window.complianceScoreByDay,
      week: window.complianceScoreByWeek,
      month: window.complianceScoreByMonth,
      all: window.complianceScoreAll
    }

    document.querySelectorAll("#chart-filter-tabs .nav-link").forEach(tab => {
      tab.addEventListener("click", e => {
        e.preventDefault();
        const filter = tab.dataset.filter;

        // Swap active class
        document.querySelectorAll("#chart-filter-tabs .nav-link").forEach(t => t.classList.remove("active"));
        tab.classList.add("active");

        // Update both charts
        pieChart.updateData(pieDataMap[filter]);
        barChart.updateData(barDataMap[filter]);
      });
    });

    document.querySelectorAll("#compliance-chart-filter-tabs .nav-link").forEach(tab => {
      tab.addEventListener("click", e => {
        e.preventDefault();
        const filter = tab.dataset.filter;

        // Swap active class
        document.querySelectorAll("#compliance-chart-filter-tabs .nav-link").forEach(t => t.classList.remove("active"));
        tab.classList.add("active");

        // Update both charts
        complianceChart.updateData(complianceDataMap[filter]);
      });
    })
  });
});




Rails.start();

import Chartkick from "chartkick"
import Chart from "chart.js/auto"  
import ChartDataLabels from 'chartjs-plugin-datalabels'  
import "chartjs-adapter-moment";

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

  waitForCharts((complianceChart) => {

    const complianceDataMap = {
      day: window.complianceScoreByDay,
      week: window.complianceScoreByWeek,
      month: window.complianceScoreByMonth,
      all: window.complianceScoreAll
    }

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




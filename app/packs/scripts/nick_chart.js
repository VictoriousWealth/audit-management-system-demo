import Chartkick from "chartkick";
import Chart from "chart.js/auto";
import ChartDataLabels from "chartjs-plugin-datalabels";
import "chartjs-adapter-moment";

// Register plugins
Chart.register(ChartDataLabels);
Chartkick.use(Chart);

// Global Chartkick options (customize colors if needed)
Chartkick.options = {
  colors: ["#42CA68", "#F39C12", "#E74C3C", "#8E44AD", "#3498DB"]
};

// Helper to wait until Chartkick renders the chart
function waitForCharts(callback, retries = 10, delay = 100) {
  const complianceChart = Chartkick.charts["complianceScoreChart"];

  if (complianceChart) {
    callback(complianceChart);
  } else if (retries > 0) {
    setTimeout(() => waitForCharts(callback, retries - 1, delay), delay);
  } else {
    console.error("Chart 'complianceScoreChart' not found.");
  }
}

// Run once DOM is ready
document.addEventListener("DOMContentLoaded", function () {
  waitForCharts((complianceChart) => {
    const complianceDataMap = {
      day: window.complianceScoreByDay,
      week: window.complianceScoreByWeek,
      month: window.complianceScoreByMonth,
      all: window.complianceScoreAll,
    };

    const labelDataMap = {
      day: window.complianceScoreByDayLabels,
      week: window.complianceScoreByWeekLabels,
      month: window.complianceScoreByMonthLabels,
      all: window.complianceScoreLabels,
    };

    function updateLabels(labels, filter) {
      const container = document.getElementById("compliance-score-labels");
      const noData = document.getElementById("no-data-msg");
    
      if (!container || !noData) return;
    
      // Clear old labels
      container.innerHTML = "";
    
      // Check if all datasets are empty
      const allEmpty = labels.every(label => label.average === 0 || isNaN(label.average) || label.average === null || label.average === "NaN");
    
      if (allEmpty || !complianceDataMap[filter]) {
        noData.style.display = "block";
        container.style.display = "none"
      } else {
        noData.style.display = "none";
        container.style.display = "block"

    
        labels.forEach((label) => {
          const p = document.createElement("p");
          p.style.color = label.color || "#000";
          p.innerHTML = `<strong>${label.name}: average=${label.average}%</strong>`;
          container.appendChild(p);
        });
      }
    }
    

    // Tab click listeners
    document.querySelectorAll("#compliance-chart-filter-tabs .nav-link").forEach((tab) => {
      tab.addEventListener("click", (e) => {
        e.preventDefault();
    
        const filter = tab.dataset.filter;
        
        // Debugging
        console.log(`🔁 Switching to: ${filter}`);
        console.log("📊 Dataset:", complianceDataMap[filter]);

        // Remove 'active' from all tabs
        document.querySelectorAll("#compliance-chart-filter-tabs .nav-link").forEach((t) =>
          t.classList.remove("active")
        );
    
        // Add 'active' to the clicked one
        tab.classList.add("active");
    
    
        // Your chart + label logic
        complianceChart.updateData(complianceDataMap[filter]);
        updateLabels(labelDataMap[filter], filter);
      });
    });
    
    updateLabels(labelDataMap["day"]);
  });
});

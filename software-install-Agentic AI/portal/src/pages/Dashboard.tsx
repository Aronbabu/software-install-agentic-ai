import { useEffect, useState } from "react";
import { getDashboardSummary } from "../api/dashboardApi";

export default function Dashboard() {
  const [summary, setSummary] = useState({
    total_jobs: 0,
    running_jobs: 0,
    success_jobs: 0,
    failed_jobs: 0,
    workers: 0,
  });

  useEffect(() => {
    getDashboardSummary().then(setSummary).catch(console.error);
  }, []);

  return (
    <div className="page">
      <div className="page-header">
        <div>
          <h1 className="page-title">Dashboard</h1>
          <p className="page-subtitle">Operational overview of jobs and workers.</p>
        </div>
      </div>

      <div className="grid-5">
        <div className="card metric">
          <div className="metric-label">Total Jobs</div>
          <div className="metric-value">{summary.total_jobs}</div>
        </div>

        <div className="card metric">
          <div className="metric-label">Running</div>
          <div className="metric-value">{summary.running_jobs}</div>
        </div>

        <div className="card metric">
          <div className="metric-label">Success</div>
          <div className="metric-value" style={{ color: "var(--success)" }}>
            {summary.success_jobs}
          </div>
        </div>

        <div className="card metric">
          <div className="metric-label">Failed</div>
          <div className="metric-value" style={{ color: "var(--danger)" }}>
            {summary.failed_jobs}
          </div>
        </div>

        <div className="card metric">
          <div className="metric-label">Workers</div>
          <div className="metric-value">{summary.workers}</div>
        </div>
      </div>
    </div>
  );
}
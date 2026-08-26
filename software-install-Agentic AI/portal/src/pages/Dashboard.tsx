import { useEffect, useState } from "react";
import { getDashboardSummary } from "../api/dashboardApi";

export default function Dashboard() {
  const [summary, setSummary] = useState({
    total_jobs: 0,
    running_jobs: 0,
    success_jobs: 0,
    failed_jobs: 0,
    workers: 0
  });

  useEffect(() => {
    getDashboardSummary()
      .then(setSummary)
      .catch(console.error);
  }, []);
  const cardStyle = {
  background: "white",
  border: "1px solid #ddd",
  borderRadius: "8px",
  padding: "20px",
  textAlign: "center" as const,
  boxShadow: "0 2px 4px rgba(0, 0, 0, 0.1)",
  transition: "transform 0.2s",
  cursor: "pointer",
};
  return (
  <div
    style={{
      maxWidth: "1200px",
      margin: "0 auto",
    }}
  >
    <h1
      style={{
        marginBottom: "20px",
      }}
    >
      Dashboard
    </h1>

    <div
      style={{
        display: "grid",
        gridTemplateColumns: "repeat(5, 1fr)",
        gap: "20px",
      }}
    >

      <div style={cardStyle}>
        <h3>Total Jobs</h3>
        <h1>{summary.total_jobs}</h1>
      </div>

      <div style={cardStyle}>
        <h3>Running</h3>
        <h1>{summary.running_jobs}</h1>
      </div>

      <div style={cardStyle}>
        <h3>Success</h3>
        <h1
          style={{
            color: "green",
          }}
        >
          {summary.success_jobs}
        </h1>
      </div>

      <div style={cardStyle}>
        <h3>Failed</h3>
        <h1
          style={{
            color: "red",
          }}
        >
          {summary.failed_jobs}
        </h1>
      </div>

      <div style={cardStyle}>
        <h3>Workers</h3>
        <h1>{summary.workers}</h1>
      </div>

    </div>
  </div>
);
}
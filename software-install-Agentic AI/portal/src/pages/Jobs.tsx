import { useEffect, useState } from "react";
import { getJobs } from "../api/jobsApi";
import type { Job } from "../types/job";
import type { JobListResponse } from "../types/job";
import StatusBadge from "../components/status/StatusBadge";
import { Link } from "react-router-dom";

export default function Jobs() {

  const [jobs, setJobs] = useState<Job[]>([]);

  useEffect(() => {
    getJobs()
      .then((data: JobListResponse) => {
        setJobs(data.items);
      })
      .catch(console.error);
  }, []);



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
      Jobs
    </h1>

    <div
      style={{
        background: "white",
        border: "1px solid #ddd",
        borderRadius: "8px",
        padding: "20px",
      }}
    >
      <table
        style={{
          width: "100%",
          borderCollapse: "collapse",
        }}
      >
        <thead>
          <tr>
            <th style={{ textAlign: "left", padding: "12px" }}>
              Ticket
            </th>

            <th style={{ textAlign: "left", padding: "12px" }}>
              Software
            </th>

            <th style={{ textAlign: "left", padding: "12px" }}>
              Status
            </th>

            <th style={{ textAlign: "left", padding: "12px" }}>
              Target Host
            </th>

            <th style={{ textAlign: "left", padding: "12px" }}>
              Port
            </th>

            <th style={{ textAlign: "left", padding: "12px" }}>
              Connection
            </th>
          </tr>
        </thead>

        <tbody>
          {jobs.map((job) => (
            <tr
              key={job.id}
              style={{
                borderBottom: "1px solid #f1f1f1",
              }}
            >
              <td style={{ padding: "12px" }}>
                <Link
                  to={`/jobs/${job.id}`}
                  style={{
                    color: "#2563eb",
                    textDecoration: "none",
                    fontWeight: "bold",
                  }}
                >
                  {job.ticket_id}
                </Link>
              </td>

              <td style={{ padding: "12px" }}>
                {job.software_name}
              </td>

              <td style={{ padding: "12px" }}>
                <StatusBadge status={job.status} />
              </td>

              <td style={{ padding: "12px" }}>
                {job.target_host}
              </td>

              <td style={{ padding: "12px" }}>
                {job.target_port}
              </td>

              <td style={{ padding: "12px" }}>
                {job.connection_method}
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  </div>
);
}
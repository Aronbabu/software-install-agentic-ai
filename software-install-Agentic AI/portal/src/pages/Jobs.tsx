import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { getJobs } from "../api/jobsApi";
import StatusBadge from "../components/status/StatusBadge";
import type { Job, JobListResponse } from "../types/job";

export default function Jobs() {
  const [jobs, setJobs] = useState<Job[]>([]);

  useEffect(() => {
    getJobs()
      .then((data: JobListResponse) => setJobs(data.items))
      .catch(console.error);
  }, []);

  return (
    <div className="page">
      <div className="page-header">
        <div>
          <h1 className="page-title">Jobs</h1>
          <p className="page-subtitle">Recent installation requests and their statuses.</p>
        </div>
      </div>

      <div className="card card-pad table-wrap">
        <table className="table">
          <thead>
            <tr>
              <th>Ticket</th>
              <th>Software</th>
              <th>Status</th>
              <th>Target Host</th>
              <th>Port</th>
              <th>Connection</th>
            </tr>
          </thead>

          <tbody>
            {jobs.map((job) => (
              <tr key={job.id}>
                <td>
                  <Link
                    to={`/jobs/${job.id}`}
                    style={{
                      color: "var(--primary)",
                      textDecoration: "none",
                      fontWeight: 700,
                    }}
                  >
                    {job.ticket_id}
                  </Link>
                </td>
                <td>{job.software_name}</td>
                <td>
                  <StatusBadge status={job.status} />
                </td>
                <td>{job.target_host}</td>
                <td>{job.target_port}</td>
                <td>{job.connection_method}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import StatusBadge from "../components/status/StatusBadge";

import {
  getJob,
  getJobProgress,
} from "../api/jobDetailsApi";

export default function JobDetails() {

  const { jobId } = useParams();

  const [job, setJob] = useState<any>(null);
  const [progress, setProgress] = useState<any>(null);

  useEffect(() => {

    if (!jobId) return;

    getJob(jobId)
      .then(setJob)
      .catch(console.error);

    getJobProgress(jobId)
      .then(setProgress)
      .catch(console.error);

  }, [jobId]);

  if (!job) {
    return <div>Loading...</div>;
  }

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
      Job Details
    </h1>

    {/* Header */}
    <div
      style={{
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        background: "white",
        padding: "20px",
        borderRadius: "8px",
        border: "1px solid #ddd",
        marginBottom: "20px",
      }}
    >
      <div>
        <h2>{job.ticket_id}</h2>
        <p>{job.software_name}</p>
      </div>

      <StatusBadge status={job.status} />
    </div>

    {/* Summary + Target */}
    <div
      style={{
        display: "grid",
        gridTemplateColumns: "1fr 1fr",
        gap: "20px",
        marginBottom: "20px",
      }}
    >
      <div
        style={{
          background: "white",
          padding: "20px",
          borderRadius: "8px",
          border: "1px solid #ddd",
        }}
      >
        <h3>Summary</h3>

        <p>
          <strong>Ticket:</strong> {job.ticket_id}
        </p>

        <p>
          <strong>Software:</strong> {job.software_name}
        </p>
      </div>

      <div
        style={{
          background: "white",
          padding: "20px",
          borderRadius: "8px",
          border: "1px solid #ddd",
        }}
      >
        <h3>Target Information</h3>

        <p>
          <strong>Host:</strong> {job.target_host}
        </p>

        <p>
          <strong>Port:</strong> {job.target_port}
        </p>

        <p>
          <strong>Connection:</strong> {job.connection_method}
        </p>
      </div>
    </div>

    {progress && (
      <>
        {/* Execution */}
        <div
          style={{
            background: "white",
            padding: "20px",
            borderRadius: "8px",
            border: "1px solid #ddd",
            marginBottom: "20px",
          }}
        >
          <h3>Execution Information</h3>

          <p>
            <strong>Retry Count:</strong>{" "}
            {progress.retry_count ?? 0}
          </p>

          <p>
            <strong>Last Error:</strong>{" "}
            {progress.last_error ?? "None"}
          </p>
        </div>

        {/* Timeline */}
        <div
          style={{
            background: "white",
            padding: "20px",
            borderRadius: "8px",
            border: "1px solid #ddd",
          }}
        >
          <h3>Execution Lifecycle</h3>

          <table
            style={{
              width: "100%",
              borderCollapse: "collapse",
            }}
          >
            <thead>
              <tr>
                <th
                  style={{
                    textAlign: "left",
                    padding: "10px",
                    borderBottom: "1px solid #ddd",
                  }}
                >
                  Step
                </th>

                <th
                  style={{
                    textAlign: "left",
                    padding: "10px",
                    borderBottom: "1px solid #ddd",
                  }}
                >
                  Status
                </th>
              </tr>
            </thead>

            <tbody>
              {progress.steps?.map((step: any) => (
                <tr key={step.id}>
                  <td
                    style={{
                      padding: "10px",
                      borderBottom:
                        "1px solid #f1f1f1",
                    }}
                  >
                    {step.step_name}
                  </td>

                  <td
                    style={{
                      padding: "10px",
                      borderBottom:
                        "1px solid #f1f1f1",
                    }}
                  >
                    <StatusBadge
                      status={step.status}
                    />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      </>
    )}
  </div>
);
}
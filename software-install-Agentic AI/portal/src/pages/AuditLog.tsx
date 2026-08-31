import { useEffect, useMemo, useState } from "react";
import { getJobs } from "../api/jobsApi";
import { getJobAuditTrail, getJobLedger } from "../api/auditApi";
import StatusBadge from "../components/status/StatusBadge";

type AuditEvent = {
  timestamp?: string;
  event_type?: string;
  result?: string;
  message?: string;
  actor_id?: string | null;
};

type Ledger = {
  job_id?: string;
  request_source?: string;
  request_reference?: string | null;
  requested_by?: string | null;
  software_name?: string | null;
  target_host?: string | null;
  connection_method?: string | null;
  authorization_result?: string | null;
  execution_result?: string | null;
  verification_result?: string | null;
  final_outcome?: string | null;
};

export default function AuditLog() {
  const [jobs, setJobs] = useState<any[]>([]);
  const [selectedJobId, setSelectedJobId] = useState<string>("");
  const [ledger, setLedger] = useState<Ledger | null>(null);
  const [events, setEvents] = useState<AuditEvent[]>([]);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    getJobs()
      .then((data) => {
        setJobs(data.items ?? []);
        if (data.items?.length && !selectedJobId) {
          setSelectedJobId(data.items[0].id);
        }
      })
      .catch(console.error);
  }, []);

  useEffect(() => {
    if (!selectedJobId) return;

    setLoading(true);

    Promise.all([
      getJobLedger(selectedJobId),
      getJobAuditTrail(selectedJobId),
    ])
      .then(([ledgerData, auditData]) => {
        setLedger(ledgerData);
        setEvents(auditData.events ?? []);
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, [selectedJobId]);

  const summary = useMemo(
    () => [
      { label: "Authorization", value: ledger?.authorization_result ?? "—" },
      { label: "Execution", value: ledger?.execution_result ?? "—" },
      { label: "Verification", value: ledger?.verification_result ?? "—" },
      { label: "Final Outcome", value: ledger?.final_outcome ?? "—" },
    ],
    [ledger]
  );

  return (
    <div className="page">
      <div className="page-header">
        <div>
          <h1 className="page-title">Audit Log</h1>
          <p className="page-subtitle">
            Review ledger state and chronological audit events for a job.
          </p>
        </div>
      </div>

      <div className="grid-2">
        <div className="card card-pad">
          <h3 className="section-title">Select Job</h3>

          <label className="form-label">
            Job
            <select
              className="form-input"
              value={selectedJobId}
              onChange={(e) => setSelectedJobId(e.target.value)}
            >
              {jobs.map((job) => (
                <option key={job.id} value={job.id}>
                  {job.ticket_id} — {job.software_name}
                </option>
              ))}
            </select>
          </label>

          <div className="spacer-16" />

          <p className="muted">
            Choose a job to inspect the ledger and event trail.
          </p>
        </div>

        <div className="card card-pad">
          <h3 className="section-title">Ledger Summary</h3>

          {loading ? (
            <p className="muted">Loading...</p>
          ) : ledger ? (
            <div style={{ display: "grid", gap: "12px" }}>
              {summary.map((item) => (
                <div
                  key={item.label}
                  style={{
                    display: "flex",
                    justifyContent: "space-between",
                    gap: "12px",
                    padding: "12px 14px",
                    border: "1px solid var(--border)",
                    borderRadius: "12px",
                    background: "#f8fafc",
                  }}
                >
                  <span className="muted">{item.label}</span>
                  <StatusBadge status={item.value} />
                </div>
              ))}
            </div>
          ) : (
            <p className="muted">No ledger available.</p>
          )}
        </div>
      </div>

      <div className="spacer-16" />

      <div className="card card-pad table-wrap">
        <h3 className="section-title">Audit Trail</h3>

        <table className="table">
          <thead>
            <tr>
              <th>Timestamp</th>
              <th>Event Type</th>
              <th>Result</th>
              <th>Message</th>
            </tr>
          </thead>

          <tbody>
            {events.map((event, index) => (
              <tr key={`${event.timestamp ?? "event"}-${index}`}>
                <td>{event.timestamp ?? "—"}</td>
                <td>{event.event_type ?? "—"}</td>
                <td>
                  <StatusBadge status={event.result ?? "—"} />
                </td>
                <td>{event.message ?? "—"}</td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
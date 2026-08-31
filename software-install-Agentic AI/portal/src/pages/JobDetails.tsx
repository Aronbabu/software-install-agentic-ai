import { useEffect, useMemo, useState } from "react";
import { useParams } from "react-router-dom";
import StatusBadge from "../components/status/StatusBadge";
import Breadcrumbs from "../components/layout/Breadcrumbs";
import { getJob, getJobProgress } from "../api/jobDetailsApi";
import { getJobAuditTrail, getJobLedger } from "../api/auditApi";

type TabKey = "summary" | "progress" | "ledger" | "audit";

type LedgerRecord = {
  id?: string;
  job_id?: string;
  request_source?: string;
  request_reference?: string | null;
  requested_by?: string | null;
  software_name?: string | null;
  target_host?: string | null;
  connection_method?: string | null;
  authorization_result?: string | null;
  authorization_reason?: string | null;
  execution_path?: string | null;
  execution_result?: string | null;
  execution_details?: string | null;
  verification_result?: string | null;
  verification_details?: string | null;
  final_outcome?: string | null;
  created_at?: string;
  updated_at?: string;
};

export default function JobDetails() {
  const { jobId } = useParams();

  const [job, setJob] = useState<any>(null);
  const [progress, setProgress] = useState<any>(null);
  const [ledger, setLedger] = useState<LedgerRecord | null>(null);
  const [auditEvents, setAuditEvents] = useState<any[]>([]);
  const [activeTab, setActiveTab] = useState<TabKey>("summary");

  useEffect(() => {
    if (!jobId) return;

    getJob(jobId).then(setJob).catch(console.error);
    getJobProgress(jobId).then(setProgress).catch(console.error);
    getJobLedger(jobId).then(setLedger).catch(console.error);
    getJobAuditTrail(jobId)
      .then((data) => setAuditEvents(data.events ?? []))
      .catch(console.error);
  }, [jobId]);

  const ledgerRows = useMemo(
    () => [
      ["Authorization", ledger?.authorization_result ?? "—"],
      ["Execution", ledger?.execution_result ?? "—"],
      ["Verification", ledger?.verification_result ?? "—"],
      ["Final Outcome", ledger?.final_outcome ?? "—"],
    ],
    [ledger]
  );

  if (!job) {
    return (
      <div className="page">
        <div className="card card-pad">Loading job details...</div>
      </div>
    );
  }

  return (
    <div className="page">
      <Breadcrumbs
        items={[
          { label: "Dashboard", to: "/" },
          { label: "Jobs", to: "/jobs" },
          { label: job.ticket_id },
        ]}
      />

      <div className="page-header">
        <div>
          <h1 className="page-title">Job Details</h1>
          <p className="page-subtitle">
            Full execution context, progress, ledger, and audit trail.
          </p>
        </div>
      </div>

      <div className="card card-pad">
        <div
          style={{
            display: "flex",
            justifyContent: "space-between",
            alignItems: "center",
            gap: "16px",
            flexWrap: "wrap",
          }}
        >
          <div>
            <h2 style={{ marginBottom: "6px" }}>{job.ticket_id}</h2>
            <p>
              {job.software_name} · {job.target_host}:{job.target_port}
            </p>
          </div>
          <StatusBadge status={job.status} />
        </div>

        <div className="spacer-16" />

        <div style={{ display: "flex", gap: "10px", flexWrap: "wrap" }}>
          {(["summary", "progress", "ledger", "audit"] as TabKey[]).map((tab) => (
            <button
              key={tab}
              type="button"
              onClick={() => setActiveTab(tab)}
              style={{
                border: "1px solid var(--border)",
                background: activeTab === tab ? "var(--primary)" : "white",
                color: activeTab === tab ? "white" : "var(--text)",
                padding: "10px 14px",
                borderRadius: "12px",
                cursor: "pointer",
                fontWeight: 700,
              }}
            >
              {tab === "summary" && "Summary"}
              {tab === "progress" && "Progress"}
              {tab === "ledger" && "Ledger"}
              {tab === "audit" && "Audit Trail"}
            </button>
          ))}
        </div>
      </div>

      <div className="spacer-16" />

      {activeTab === "summary" && (
        <div className="grid-2">
          <div className="card card-pad">
            <h3 className="section-title">Summary</h3>
            <p><strong>Ticket:</strong> {job.ticket_id}</p>
            <div className="spacer-16" />
            <p><strong>Software:</strong> {job.software_name}</p>
            <div className="spacer-16" />
            <p><strong>Version:</strong> {job.software_version ?? "—"}</p>
            <div className="spacer-16" />
            <p><strong>Requested By:</strong> {job.requested_by ?? "—"}</p>
          </div>

          <div className="card card-pad">
            <h3 className="section-title">Target Information</h3>
            <p><strong>Host:</strong> {job.target_host}</p>
            <div className="spacer-16" />
            <p><strong>Port:</strong> {job.target_port}</p>
            <div className="spacer-16" />
            <p><strong>Connection:</strong> {job.connection_method}</p>
            <div className="spacer-16" />
            <p><strong>OS:</strong> {job.os_type}</p>
          </div>
        </div>
      )}

      {activeTab === "progress" && (
        <div className="grid-2">
          <div className="card card-pad">
            <h3 className="section-title">Execution Information</h3>
            <p><strong>Retry Count:</strong> {progress?.retry_count ?? 0}</p>
            <div className="spacer-16" />
            <p><strong>Max Retries:</strong> {progress?.max_retries ?? 0}</p>
            <div className="spacer-16" />
            <p><strong>Last Error:</strong> {progress?.last_error ?? "None"}</p>
          </div>

          <div className="card card-pad table-wrap">
            <h3 className="section-title">Execution Steps</h3>
            <table className="table">
              <thead>
                <tr>
                  <th>Step</th>
                  <th>Status</th>
                  <th>Message</th>
                </tr>
              </thead>
              <tbody>
                {progress?.steps?.map((step: any) => (
                  <tr key={step.id}>
                    <td>{step.step_name}</td>
                    <td>
                      <StatusBadge status={step.status} />
                    </td>
                    <td>{step.message ?? "—"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {activeTab === "ledger" && (
        <div className="grid-2">
          <div className="card card-pad">
            <h3 className="section-title">Ledger Summary</h3>

            {ledger ? (
              <div style={{ display: "grid", gap: "12px" }}>
                {ledgerRows.map(([label, value]) => (
                  <div
                    key={label}
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
                    <span className="muted">{label}</span>
                    <StatusBadge status={String(value)} />
                  </div>
                ))}
              </div>
            ) : (
              <p className="muted">Ledger not available.</p>
            )}
          </div>

          <div className="card card-pad">
            <h3 className="section-title">Ledger Details</h3>
            <p><strong>Requested By:</strong> {ledger?.requested_by ?? "—"}</p>
            <div className="spacer-16" />
            <p><strong>Request Source:</strong> {ledger?.request_source ?? "—"}</p>
            <div className="spacer-16" />
            <p><strong>Reference:</strong> {ledger?.request_reference ?? "—"}</p>
            <div className="spacer-16" />
            <p><strong>Execution Path:</strong> {ledger?.execution_path ?? "—"}</p>
          </div>
        </div>
      )}

      {activeTab === "audit" && (
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
              {auditEvents.map((event, index) => (
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
      )}
    </div>
  );
}
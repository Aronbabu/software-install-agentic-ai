import { useEffect, useMemo, useState } from "react";
import { useParams } from "react-router-dom";
import StatusBadge from "../components/status/StatusBadge";
import Breadcrumbs from "../components/layout/Breadcrumbs";
import { getJob, getJobProgress, resolveJobReview } from "../api/jobDetailsApi";
import { getJobAuditTrail, getJobLedger } from "../api/auditApi";

type TabKey = "summary" | "progress" | "ledger" | "audit" | "review";

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

type ReviewPayload = {
  resolution_type: "REUSE_PLAN" | "USE_SOP" | "APPROVE_AI_PLAN" | "DEFER_TO_MANUAL";
  selected_plan_id?: string;
  selected_sop_id?: string;
  operator_notes?: string;
  auto_queue_execution?: boolean;
};

export default function JobDetails() {
  const { jobId } = useParams();

  const [job, setJob] = useState<any>(null);
  const [progress, setProgress] = useState<any>(null);
  const [ledger, setLedger] = useState<LedgerRecord | null>(null);
  const [auditEvents, setAuditEvents] = useState<any[]>([]);
  const [activeTab, setActiveTab] = useState<TabKey>("summary");

  const [reviewForm, setReviewForm] = useState<ReviewPayload>({
    resolution_type: "USE_SOP",
    selected_plan_id: "",
    selected_sop_id: "",
    operator_notes: "",
    auto_queue_execution: true,
  });

  const [reviewSubmitting, setReviewSubmitting] = useState(false);
  const [reviewMessage, setReviewMessage] = useState<string>("");

  useEffect(() => {
    if (!jobId) return;

    getJob(jobId).then(setJob).catch(console.error);
    getJobProgress(jobId).then(setProgress).catch(console.error);
    getJobLedger(jobId).then(setLedger).catch(console.error);
    getJobAuditTrail(jobId)
      .then((data) => setAuditEvents(data.events ?? []))
      .catch(console.error);
  }, [jobId]);

  useEffect(() => {
    if (reviewForm.resolution_type === "DEFER_TO_MANUAL") {
      setReviewForm((prev) => ({
        ...prev,
        selected_plan_id: "",
        selected_sop_id: "",
        auto_queue_execution: false,
      }));
    }
  }, [reviewForm.resolution_type]);

  const ledgerRows = useMemo(
    () => [
      ["Authorization", ledger?.authorization_result ?? "—"],
      ["Execution", ledger?.execution_result ?? "—"],
      ["Verification", ledger?.verification_result ?? "—"],
      ["Final Outcome", ledger?.final_outcome ?? "—"],
    ],
    [ledger]
  );

  const reviewRequired = job?.status === "REVIEW_REQUIRED";
  const showPlanInputs =
    reviewForm.resolution_type === "REUSE_PLAN" ||
    reviewForm.resolution_type === "APPROVE_AI_PLAN";
  const showSopInput = reviewForm.resolution_type === "USE_SOP";

  const handleResolveReview = async () => {
    if (!jobId) return;

    setReviewSubmitting(true);
    setReviewMessage("");

    try {
      const payload: ReviewPayload = {
        resolution_type: reviewForm.resolution_type,
        selected_plan_id: reviewForm.selected_plan_id?.trim() || undefined,
        selected_sop_id: reviewForm.selected_sop_id?.trim() || undefined,
        operator_notes: reviewForm.operator_notes?.trim() || undefined,
        auto_queue_execution:
          reviewForm.resolution_type === "DEFER_TO_MANUAL"
            ? false
            : reviewForm.auto_queue_execution,
      };

      await resolveJobReview(jobId, payload);
      setReviewMessage("Review resolved successfully. Refreshing job details...");

      const [updatedJob, updatedProgress, updatedLedger, updatedAudit] = await Promise.all([
        getJob(jobId),
        getJobProgress(jobId),
        getJobLedger(jobId),
        getJobAuditTrail(jobId),
      ]);

      setJob(updatedJob);
      setProgress(updatedProgress);
      setLedger(updatedLedger);
      setAuditEvents(updatedAudit.events ?? []);
      setActiveTab("summary");
    } catch (err: any) {
      setReviewMessage(err?.response?.data?.detail ?? "Failed to resolve review.");
    } finally {
      setReviewSubmitting(false);
    }
  };

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

        {reviewRequired && (
          <div
            style={{
              marginTop: "16px",
              padding: "14px",
              borderRadius: "12px",
              border: "1px solid #f59e0b",
              background: "#fffbeb",
            }}
          >
            <h3 style={{ marginBottom: "8px" }}>Review Required</h3>
            <p style={{ marginBottom: "8px" }}>
              <strong>Reason:</strong> {job.review_reason ?? "Manual review required."}
            </p>
            <p style={{ marginBottom: "8px" }}>
              <strong>Operator Action:</strong> Review the advisory notes and choose a resolution.
            </p>
            <button
              type="button"
              onClick={() => setActiveTab("review")}
              style={{
                border: "none",
                background: "var(--primary)",
                color: "white",
                padding: "10px 14px",
                borderRadius: "10px",
                cursor: "pointer",
                fontWeight: 700,
              }}
            >
              Resolve Review
            </button>
          </div>
        )}

        <div className="spacer-16" />

        <div style={{ display: "flex", gap: "10px", flexWrap: "wrap" }}>
          {(["summary", "progress", "ledger", "audit", "review"] as TabKey[]).map((tab) => (
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
              {tab === "review" && "Review"}
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
            <div className="spacer-16" />
            <p><strong>Review Reason:</strong> {job.review_reason ?? "—"}</p>
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

      {activeTab === "review" && (
        <div className="grid-2">
          <div className="card card-pad">
            <h3 className="section-title">Review Details</h3>
            <p><strong>Status:</strong> {job.status}</p>
            <div className="spacer-16" />
            <p><strong>Reason:</strong> {job.review_reason ?? "—"}</p>
            <div className="spacer-16" />
            <p><strong>Notes:</strong> {job.notes ?? "—"}</p>
            <div className="spacer-16" />
            <p><strong>Selected Plan:</strong> {job.current_plan_id ?? "—"}</p>
          </div>

          <div className="card card-pad">
            <h3 className="section-title">Resolve Review</h3>

            <div style={{ display: "grid", gap: "12px" }}>
              <label>
                <div className="muted">Resolution Type</div>
                <select
                  value={reviewForm.resolution_type}
                  onChange={(e) =>
                    setReviewForm((prev) => ({
                      ...prev,
                      resolution_type: e.target.value as ReviewPayload["resolution_type"],
                    }))
                  }
                  style={{ width: "100%", padding: "10px", borderRadius: "10px" }}
                >
                  <option value="USE_SOP">USE_SOP</option>
                  <option value="REUSE_PLAN">REUSE_PLAN</option>
                  <option value="APPROVE_AI_PLAN">APPROVE_AI_PLAN</option>
                  <option value="DEFER_TO_MANUAL">DEFER_TO_MANUAL</option>
                </select>
              </label>

              {reviewForm.resolution_type === "DEFER_TO_MANUAL" && (
                <div
                  style={{
                    padding: "12px 14px",
                    borderRadius: "10px",
                    background: "#f8fafc",
                    border: "1px solid var(--border)",
                  }}
                >
                  This will keep the job in <strong>REVIEW_REQUIRED</strong> and will not resume execution.
                </div>
              )}

              {showPlanInputs && (
                <label>
                  <div className="muted">Selected Plan ID</div>
                  <input
                    type="text"
                    value={reviewForm.selected_plan_id}
                    onChange={(e) =>
                      setReviewForm((prev) => ({
                        ...prev,
                        selected_plan_id: e.target.value,
                      }))
                    }
                    placeholder="Optional: approved plan id"
                    style={{ width: "100%", padding: "10px", borderRadius: "10px" }}
                  />
                </label>
              )}

              {showSopInput && (
                <label>
                  <div className="muted">Selected SOP ID</div>
                  <input
                    type="text"
                    value={reviewForm.selected_sop_id}
                    onChange={(e) =>
                      setReviewForm((prev) => ({
                        ...prev,
                        selected_sop_id: e.target.value,
                      }))
                    }
                    placeholder="Optional: approved SOP id"
                    style={{ width: "100%", padding: "10px", borderRadius: "10px" }}
                  />
                </label>
              )}

              <label>
                <div className="muted">Operator Notes</div>
                <textarea
                  value={reviewForm.operator_notes}
                  onChange={(e) =>
                    setReviewForm((prev) => ({
                      ...prev,
                      operator_notes: e.target.value,
                    }))
                  }
                  rows={4}
                  placeholder="Explain why this resolution is approved"
                  style={{ width: "100%", padding: "10px", borderRadius: "10px" }}
                />
              </label>

              {reviewForm.resolution_type !== "DEFER_TO_MANUAL" && (
                <label style={{ display: "flex", gap: "8px", alignItems: "center" }}>
                  <input
                    type="checkbox"
                    checked={reviewForm.auto_queue_execution}
                    onChange={(e) =>
                      setReviewForm((prev) => ({
                        ...prev,
                        auto_queue_execution: e.target.checked,
                      }))
                    }
                  />
                  Auto-queue execution after resolution
                </label>
              )}

              <button
                type="button"
                onClick={handleResolveReview}
                disabled={reviewSubmitting}
                style={{
                  border: "none",
                  background: reviewSubmitting ? "#94a3b8" : "var(--primary)",
                  color: "white",
                  padding: "12px 16px",
                  borderRadius: "10px",
                  cursor: reviewSubmitting ? "not-allowed" : "pointer",
                  fontWeight: 700,
                }}
              >
                {reviewSubmitting ? "Resolving..." : "Submit Resolution"}
              </button>

              {reviewMessage && <p className="muted">{reviewMessage}</p>}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
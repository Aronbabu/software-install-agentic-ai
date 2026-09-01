import { useEffect, useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import Breadcrumbs from "../components/layout/Breadcrumbs";
import StatusBadge from "../components/status/StatusBadge";
import { api } from "../api/client";

type CatalogueItem = {
  id: string;
  name: string;
  version: string;
  os_type: string;
  request_source: "ADMIN_PORTAL" | "SERVICENOW" | "BOTH";
  execution_mode: "immediate" | "scheduled";
  target_port?: string;
  connection_method?: string;
  status: "ACTIVE" | "INACTIVE";
  notes?: string;
};

type FilterKey = "ALL" | "ADMIN_PORTAL" | "SERVICENOW" | "BOTH";

const emptyForm = {
  ticket_id: "",
  target_host: "",
  target_port: "22",
  requested_by: "",
  os_type: "linux",
  software_name: "",
  software_version: "",
  connection_method: "openssh",
  request_source: "ADMIN_PORTAL",
  request_reference: "",
  justification: "",
  notes: "",
};

export default function Catalogue() {
  const navigate = useNavigate();
  const [filter, setFilter] = useState<FilterKey>("ALL");
  const [catalogue, setCatalogue] = useState<CatalogueItem[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  // Manual request form state
  const [showForm, setShowForm] = useState(false);
  const [form, setForm] = useState(emptyForm);
  const [submitting, setSubmitting] = useState(false);
  const [formError, setFormError] = useState<string | null>(null);

  useEffect(() => {
    const fetchCatalogue = async () => {
      try {
        const response = await api.get("/catalogue");
        setCatalogue(response.data.items ?? []);
      } catch (err) {
        console.error("Failed to load catalogue", err);
        setError("Failed to load catalogue items.");
      } finally {
        setLoading(false);
      }
    };
    fetchCatalogue();
  }, []);

  const items = useMemo(() => {
    if (filter === "ALL") return catalogue;
    return catalogue.filter(
      (item) =>
        item.request_source === filter || item.request_source === "BOTH"
    );
  }, [filter, catalogue]);

  const handleCreateJob = (catalogueId: string) => {
    navigate(`/jobs/new?catalogue_id=${catalogueId}`);
  };

  const handleFormChange = (
    e: React.ChangeEvent<
      HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement
    >
  ) => {
    const { name, value } = e.target;
    setForm((prev) => ({ ...prev, [name]: value }));
  };

  const handleManualSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setFormError(null);

    if (!form.ticket_id || !form.target_host || !form.requested_by || !form.software_name) {
      setFormError("Ticket ID, Target Host, Requested By, and Software Name are required.");
      return;
    }

    setSubmitting(true);
    try {
      const payload = {
        ticket_id: form.ticket_id,
        target_host: form.target_host,
        target_port: form.target_port ? Number(form.target_port) : 22,
        requested_by: form.requested_by,
        os_type: form.os_type,
        software_name: form.software_name,
        software_version: form.software_version || null,
        connection_method: form.connection_method,
        request_source: form.request_source,
        request_reference: form.request_reference || null,
        justification: form.justification || null,
        notes: form.notes || null,
      };

      const response = await api.post("/jobs", payload);
      navigate(`/jobs/${response.data.id}`);
    } catch (err: any) {
      console.error("Job creation failed", err);
      const detail =
        err?.response?.data?.detail || "Job creation failed. Please check the inputs.";
      setFormError(typeof detail === "string" ? detail : JSON.stringify(detail));
    } finally {
      setSubmitting(false);
    }
  };

  const handleCancelForm = () => {
    setShowForm(false);
    setForm(emptyForm);
    setFormError(null);
  };

  if (loading) {
    return (
      <div className="page">
        <div className="card card-pad">Loading catalogue...</div>
      </div>
    );
  }

  if (error) {
    return (
      <div className="page">
        <div className="card card-pad" style={{ color: "red" }}>
          {error}
        </div>
      </div>
    );
  }

  return (
    <div className="page">
      <Breadcrumbs
        items={[
          { label: "Dashboard", to: "/" },
          { label: "Catalogue" },
        ]}
      />

      {/* ── Page Header with New Request button ── */}
      <div className="page-header">
        <div>
          <h1 className="page-title">Catalogue</h1>
          <p className="page-subtitle">
            Approved software inventory for portal and ServiceNow request paths.
          </p>
        </div>
        <button
          type="button"
          onClick={() => setShowForm((v) => !v)}
          style={{
            border: "none",
            background: showForm ? "#64748b" : "#2563eb",
            color: "white",
            padding: "10px 20px",
            borderRadius: "10px",
            cursor: "pointer",
            fontWeight: 700,
            fontSize: "14px",
            alignSelf: "flex-start",
          }}
        >
          {showForm ? "✕ Cancel Request" : "+ New Software Request"}
        </button>
      </div>

      {/* ── Manual Request Form (inline, shown at top) ── */}
      {showForm && (
        <div
          className="card card-pad"
          style={{ marginBottom: "24px", borderLeft: "4px solid #2563eb" }}
        >
          <h3 className="section-title" style={{ marginBottom: "16px" }}>
            Manual Software Request
          </h3>

          {formError && (
            <div
              style={{
                background: "#fef2f2",
                border: "1px solid #fca5a5",
                color: "#b91c1c",
                padding: "10px 14px",
                borderRadius: "8px",
                marginBottom: "14px",
                fontSize: "13px",
              }}
            >
              {formError}
            </div>
          )}

          <form
            onSubmit={handleManualSubmit}
            style={{
              display: "grid",
              gridTemplateColumns: "1fr 1fr",
              gap: "14px",
            }}
          >
            {/* Column 1 */}
            <label style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
              <span style={{ fontWeight: 600, fontSize: "13px" }}>
                Ticket ID <span style={{ color: "red" }}>*</span>
              </span>
              <input
                className="form-input"
                name="ticket_id"
                value={form.ticket_id}
                onChange={handleFormChange}
                placeholder="RITM9000301"
                required
              />
            </label>

            <label style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
              <span style={{ fontWeight: 600, fontSize: "13px" }}>
                Requested By <span style={{ color: "red" }}>*</span>
              </span>
              <input
                className="form-input"
                name="requested_by"
                value={form.requested_by}
                onChange={handleFormChange}
                placeholder="aron"
                required
              />
            </label>

            <label style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
              <span style={{ fontWeight: 600, fontSize: "13px" }}>
                Target Host <span style={{ color: "red" }}>*</span>
              </span>
              <input
                className="form-input"
                name="target_host"
                value={form.target_host}
                onChange={handleFormChange}
                placeholder="host.docker.internal"
                required
              />
            </label>

            <label style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
              <span style={{ fontWeight: 600, fontSize: "13px" }}>Target Port</span>
              <input
                className="form-input"
                name="target_port"
                type="number"
                value={form.target_port}
                onChange={handleFormChange}
                placeholder="22"
              />
            </label>

            <label style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
              <span style={{ fontWeight: 600, fontSize: "13px" }}>
                Software Name <span style={{ color: "red" }}>*</span>
              </span>
              <input
                className="form-input"
                name="software_name"
                value={form.software_name}
                onChange={handleFormChange}
                placeholder="vim"
                required
              />
            </label>

            <label style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
              <span style={{ fontWeight: 600, fontSize: "13px" }}>Software Version</span>
              <input
                className="form-input"
                name="software_version"
                value={form.software_version}
                onChange={handleFormChange}
                placeholder="latest"
              />
            </label>

            <label style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
              <span style={{ fontWeight: 600, fontSize: "13px" }}>OS Type</span>
              <select
                className="form-input"
                name="os_type"
                value={form.os_type}
                onChange={handleFormChange}
              >
                <option value="linux">Linux</option>
                <option value="windows">Windows</option>
              </select>
            </label>

            <label style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
              <span style={{ fontWeight: 600, fontSize: "13px" }}>Connection Method</span>
              <select
                className="form-input"
                name="connection_method"
                value={form.connection_method}
                onChange={handleFormChange}
              >
                <option value="openssh">OpenSSH</option>
                <option value="winrm">WinRM</option>
              </select>
            </label>

            <label style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
              <span style={{ fontWeight: 600, fontSize: "13px" }}>Request Source</span>
              <select
                className="form-input"
                name="request_source"
                value={form.request_source}
                onChange={handleFormChange}
              >
                <option value="ADMIN_PORTAL">ADMIN_PORTAL</option>
                <option value="SERVICENOW">SERVICENOW</option>
              </select>
            </label>

            <label style={{ display: "flex", flexDirection: "column", gap: "4px" }}>
              <span style={{ fontWeight: 600, fontSize: "13px" }}>Request Reference</span>
              <input
                className="form-input"
                name="request_reference"
                value={form.request_reference}
                onChange={handleFormChange}
                placeholder="SNOW-REF-1234"
              />
            </label>

            {/* Full-width fields */}
            <label
              style={{
                display: "flex",
                flexDirection: "column",
                gap: "4px",
                gridColumn: "1 / -1",
              }}
            >
              <span style={{ fontWeight: 600, fontSize: "13px" }}>Justification</span>
              <textarea
                className="form-input"
                name="justification"
                value={form.justification}
                onChange={handleFormChange}
                placeholder="Why is this software needed?"
                rows={2}
              />
            </label>

            <label
              style={{
                display: "flex",
                flexDirection: "column",
                gap: "4px",
                gridColumn: "1 / -1",
              }}
            >
              <span style={{ fontWeight: 600, fontSize: "13px" }}>Notes</span>
              <textarea
                className="form-input"
                name="notes"
                value={form.notes}
                onChange={handleFormChange}
                placeholder="Optional notes"
                rows={2}
              />
            </label>

            {/* Actions */}
            <div
              style={{
                gridColumn: "1 / -1",
                display: "flex",
                gap: "12px",
                justifyContent: "flex-end",
              }}
            >
              <button
                type="button"
                onClick={handleCancelForm}
                style={{
                  border: "1px solid var(--border)",
                  background: "white",
                  color: "var(--text)",
                  padding: "10px 20px",
                  borderRadius: "8px",
                  cursor: "pointer",
                  fontWeight: 600,
                }}
              >
                Cancel
              </button>
              <button
                type="submit"
                disabled={submitting}
                className="primary-button"
                style={{ padding: "10px 28px" }}
              >
                {submitting ? "Submitting..." : "Submit Request"}
              </button>
            </div>
          </form>
        </div>
      )}

      {/* ── Filter Bar ── */}
      <div className="card card-pad">
        <div style={{ display: "flex", gap: "10px", flexWrap: "wrap" }}>
          {(["ALL", "ADMIN_PORTAL", "SERVICENOW", "BOTH"] as FilterKey[]).map(
            (key) => (
              <button
                key={key}
                type="button"
                onClick={() => setFilter(key)}
                style={{
                  border: "1px solid var(--border)",
                  background: filter === key ? "var(--primary)" : "white",
                  color: filter === key ? "white" : "var(--text)",
                  padding: "10px 14px",
                  borderRadius: "12px",
                  cursor: "pointer",
                  fontWeight: 700,
                }}
              >
                {key === "ALL"
                  ? "All"
                  : key === "ADMIN_PORTAL"
                  ? "Portal"
                  : key === "SERVICENOW"
                  ? "ServiceNow"
                  : "Both"}
              </button>
            )
          )}
        </div>
      </div>

      <div className="spacer-16" />

      {/* ── Catalogue Table ── */}
      <div className="card card-pad table-wrap">
        <table className="table">
          <thead>
            <tr>
              <th>Software</th>
              <th>Version</th>
              <th>OS</th>
              <th>Request Source</th>
              <th>Method</th>
              <th>Port</th>
              <th>Status</th>
              <th>Notes</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            {items.length === 0 ? (
              <tr>
                <td
                  colSpan={9}
                  style={{ textAlign: "center", padding: "24px" }}
                >
                  No catalogue items found.
                </td>
              </tr>
            ) : (
              items.map((item) => (
                <tr key={item.id}>
                  <td>{item.name}</td>
                  <td>{item.version}</td>
                  <td>{item.os_type}</td>
                  <td>{item.request_source}</td>
                  <td>{item.connection_method ?? "—"}</td>
                  <td>{item.target_port ?? "—"}</td>
                  <td>
                    <StatusBadge status={item.status} />
                  </td>
                  <td>{item.notes ?? "—"}</td>
                  <td>
                    <button
                      type="button"
                      onClick={() => handleCreateJob(item.id)}
                      disabled={item.status !== "ACTIVE"}
                      style={{
                        border: "none",
                        background:
                          item.status === "ACTIVE" ? "#2563eb" : "#94a3b8",
                        color: "white",
                        padding: "8px 12px",
                        borderRadius: "8px",
                        cursor:
                          item.status === "ACTIVE" ? "pointer" : "not-allowed",
                        fontWeight: 600,
                      }}
                    >
                      Create Job
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
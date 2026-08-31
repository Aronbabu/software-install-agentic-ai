import { useEffect, useState } from "react";
import { useNavigate, useSearchParams } from "react-router-dom";
import Breadcrumbs from "../components/layout/Breadcrumbs";
import { api } from "../api/client";

type CatalogueItem = {
  id: string;
  name: string;
  version: string;
  os_type: string;
  request_source: string;
  execution_mode: string;
  target_port?: string;
  connection_method?: string;
  status: string;
  notes?: string;
};

export default function NewJobRequest() {
  const navigate = useNavigate();
  const [searchParams] = useSearchParams();
  const catalogueId = searchParams.get("catalogue_id");

  const [catalogueItem, setCatalogueItem] = useState<CatalogueItem | null>(null);
  const [loading, setLoading] = useState(true);
  const [submitting, setSubmitting] = useState(false);

  const [form, setForm] = useState({
    target_host: "",
    target_port: "",
    requested_by: "",
    request_source: "ADMIN_PORTAL",
    request_reference: "",
    notes: "",
    ticket_id: "",
    justification: "",
  });

  useEffect(() => {
    const loadCatalogueItem = async () => {
      if (!catalogueId) {
        setLoading(false);
        return;
      }

      try {
        const response = await api.get(`/catalogue/${catalogueId}`);
        const item = response.data;
        setCatalogueItem(item);

        setForm((prev) => ({
          ...prev,
          request_source:
            item.request_source === "SERVICENOW"
              ? "SERVICENOW"
              : "ADMIN_PORTAL",
          target_port: item.target_port ? String(item.target_port) : "",
        }));
      } catch (error) {
        console.error("Failed to load catalogue item", error);
      } finally {
        setLoading(false);
      }
    };

    loadCatalogueItem();
  }, [catalogueId]);

  const handleChange = (
    e: React.ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>
  ) => {
    const { name, value } = e.target;
    setForm((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    if (!catalogueId) {
      alert("Missing catalogue item");
      return;
    }

    setSubmitting(true);

    try {
      const payload = {
        catalogue_id: catalogueId,
        target_host: form.target_host,
        target_port: form.target_port ? Number(form.target_port) : null,
        requested_by: form.requested_by,
        request_source: form.request_source,
        request_reference: form.request_reference || null,
        notes: form.notes || null,
        ticket_id: form.ticket_id || `PORTAL-${Date.now()}`,
        justification:
          form.justification || `Requested from catalogue: ${catalogueItem?.name}`,
      };

      const response = await api.post("/jobs", payload);

      navigate(`/jobs/${response.data.id}`);
    } catch (error) {
      console.error("Job creation failed", error);
      alert("Job creation failed. Please check the inputs and try again.");
    } finally {
      setSubmitting(false);
    }
  };

  if (loading) {
    return (
      <div className="page">
        <div className="card card-pad">Loading catalogue item...</div>
      </div>
    );
  }

  if (!catalogueId) {
    return (
      <div className="page">
        <div className="card card-pad">
          Missing catalogue item. Please go back and select a software item first.
        </div>
      </div>
    );
  }

  return (
    <div className="page">
      <Breadcrumbs
        items={[
          { label: "Dashboard", to: "/" },
          { label: "Catalogue", to: "/catalogue" },
          { label: "New Job Request" },
        ]}
      />

      <div className="page-header">
        <div>
          <h1 className="page-title">New Job Request</h1>
          <p className="page-subtitle">
            Create a portal request using the selected catalogue item.
          </p>
        </div>
      </div>

      <div className="grid-2">
        <div className="card card-pad">
          <h3 className="section-title">Selected Software</h3>

          {catalogueItem ? (
            <div style={{ display: "grid", gap: "12px" }}>
              <p><strong>Name:</strong> {catalogueItem.name}</p>
              <p><strong>Version:</strong> {catalogueItem.version}</p>
              <p><strong>OS:</strong> {catalogueItem.os_type}</p>
              <p><strong>Request Source:</strong> {catalogueItem.request_source}</p>
              <p><strong>Execution Mode:</strong> {catalogueItem.execution_mode}</p>
              <p><strong>Target Port:</strong> {catalogueItem.target_port ?? "—"}</p>
              <p><strong>Connection Method:</strong> {catalogueItem.connection_method ?? "—"}</p>
              <p><strong>Notes:</strong> {catalogueItem.notes ?? "—"}</p>
            </div>
          ) : (
            <p>No catalogue item found.</p>
          )}
        </div>

        <div className="card card-pad">
          <h3 className="section-title">Request Details</h3>

          <form onSubmit={handleSubmit} style={{ display: "grid", gap: "14px" }}>
            <label>
              Target Host
              <input
                className="form-input"
                name="target_host"
                value={form.target_host}
                onChange={handleChange}
                placeholder="host.example.internal"
                required
              />
            </label>

            <label>
              Target Port
              <input
                className="form-input"
                name="target_port"
                value={form.target_port}
                onChange={handleChange}
                placeholder="2221"
                type="number"
              />
            </label>

            <label>
              Requested By
              <input
                className="form-input"
                name="requested_by"
                value={form.requested_by}
                onChange={handleChange}
                placeholder="aron"
                required
              />
            </label>

            <label>
              Request Source
              <select
                className="form-input"
                name="request_source"
                value={form.request_source}
                onChange={handleChange}
                required
              >
                <option value="ADMIN_PORTAL">ADMIN_PORTAL</option>
                <option value="SERVICENOW">SERVICENOW</option>
              </select>
            </label>

            <label>
              Ticket ID
              <input
                className="form-input"
                name="ticket_id"
                value={form.ticket_id}
                onChange={handleChange}
                placeholder="RITM9000301"
              />
            </label>

            <label>
              Request Reference
              <input
                className="form-input"
                name="request_reference"
                value={form.request_reference}
                onChange={handleChange}
                placeholder="SNOW-REF-1234"
              />
            </label>

            <label>
              Justification
              <textarea
                className="form-input"
                name="justification"
                value={form.justification}
                onChange={handleChange}
                placeholder="Why is this job needed?"
                rows={3}
              />
            </label>

            <label>
              Notes
              <textarea
                className="form-input"
                name="notes"
                value={form.notes}
                onChange={handleChange}
                placeholder="Optional notes"
                rows={3}
              />
            </label>

            <button className="primary-button" type="submit" disabled={submitting}>
              {submitting ? "Creating..." : "Create Job"}
            </button>
          </form>
        </div>
      </div>
    </div>
  );
}
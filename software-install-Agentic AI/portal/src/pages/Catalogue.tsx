import { useMemo, useState } from "react";
import { useNavigate } from "react-router-dom";
import Breadcrumbs from "../components/layout/Breadcrumbs";
import StatusBadge from "../components/status/StatusBadge";

type CatalogueItem = {
  id: string;
  name: string;
  version: string;
  os: string;
  request_source: "ADMIN_PORTAL" | "SERVICENOW" | "BOTH";
  execution_mode: "immediate" | "scheduled";
  port: number;
  method: string;
  status: "ACTIVE" | "INACTIVE";
  notes: string;
};

const catalogueSeed: CatalogueItem[] = [
  {
    id: "1",
    name: "curl",
    version: "latest",
    os: "linux",
    request_source: "BOTH",
    execution_mode: "immediate",
    port: 22,
    method: "openssh",
    status: "ACTIVE",
    notes: "Used for Linux install validation/testing.",
  },
  {
    id: "2",
    name: "7-Zip",
    version: "23.01",
    os: "windows",
    request_source: "SERVICENOW",
    execution_mode: "immediate",
    port: 5985,
    method: "winrm",
    status: "ACTIVE",
    notes: "Windows package install request item.",
  },
  {
    id: "3",
    name: "Git",
    version: "2.45",
    os: "linux",
    request_source: "ADMIN_PORTAL",
    execution_mode: "immediate",
    port: 22,
    method: "openssh",
    status: "ACTIVE",
    notes: "Portal testing and developer utility.",
  },
];

type FilterKey = "ALL" | "ADMIN_PORTAL" | "SERVICENOW" | "BOTH";

export default function Catalogue() {
  const navigate = useNavigate();
  const [filter, setFilter] = useState<FilterKey>("ALL");

  const items = useMemo(() => {
    if (filter === "ALL") return catalogueSeed;
    return catalogueSeed.filter(
      (item) =>
        item.request_source === filter || item.request_source === "BOTH"
    );
  }, [filter]);

  const handleCreateJob = (catalogueId: string) => {
    navigate(`/jobs/new?catalogue_id=${catalogueId}`);
  };

  return (
    <div className="page">
      <Breadcrumbs
        items={[
          { label: "Dashboard", to: "/" },
          { label: "Catalogue" },
        ]}
      />

      <div className="page-header">
        <div>
          <h1 className="page-title">Catalogue</h1>
          <p className="page-subtitle">
            Approved software inventory for portal and ServiceNow request paths.
          </p>
        </div>
      </div>

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
            {items.map((item) => (
              <tr key={item.id}>
                <td>{item.name}</td>
                <td>{item.version}</td>
                <td>{item.os}</td>
                <td>{item.request_source}</td>
                <td>{item.method}</td>
                <td>{item.port}</td>
                <td>
                  <StatusBadge status={item.status} />
                </td>
                <td>{item.notes}</td>
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
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
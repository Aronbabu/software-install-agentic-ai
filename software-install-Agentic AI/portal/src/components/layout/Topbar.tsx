import { Link } from "react-router-dom";

export default function Topbar() {
  return (
    <div
      style={{
        background: "#ffffff",
        padding: "15px 20px",
        borderBottom: "1px solid #ddd",
      }}
    >
      <Link
        to="/"
        style={{
          textDecoration: "none",
          color: "#2563eb",
          fontSize: "24px",
          fontWeight: "bold",
        }}
      >
        Agentic AI Platform
      </Link>

      <div
        style={{
          fontSize: "14px",
          color: "#666",
          marginTop: "4px",
        }}
      >
        Development Environment
      </div>
    </div>
  );
}
import { NavLink } from "react-router-dom";

const menuItems = [
  { name: "Dashboard", path: "/" },
  { name: "Jobs", path: "/jobs" },
  { name: "Workers", path: "/workers" },
  { name: "Audit", path: "/audit" },
  { name: "Decision Ledger", path: "/ledger" },
  { name: "Software Catalog", path: "/catalog" },
  { name: "Authorization", path: "/authorization" },
  { name: "Settings", path: "/settings" },
];

export default function Sidebar() {
  return (
    <div
      style={{
        width: "250px",
        background: "#1e293b",
        color: "white",
        minHeight: "100vh",
        padding: "20px",
      }}
    >
      <h2>Agentic AI Platform</h2>

      <div
        style={{
          display: "flex",
          flexDirection: "column",
          gap: "10px",
          marginTop: "20px",
        }}
      >
        {menuItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            style={{
              color: "white",
              textDecoration: "none",
              padding: "8px",
              borderRadius: "4px",
            }}
          >
            {item.name}
          </NavLink>
        ))}
      </div>
    </div>
  );
}
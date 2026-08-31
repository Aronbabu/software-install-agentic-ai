import { NavLink } from "react-router-dom";

type MenuItem = {
  name: string;
  path: string;
  icon: string;
};

const menuItems: MenuItem[] = [
  { name: "Dashboard", path: "/", icon: "📊" },
  { name: "Jobs", path: "/jobs", icon: "🧩" },
  { name: "Audit Log", path: "/audit-log", icon: "📝" },
  { name: "Decision Ledger", path: "/ledger", icon: "📘" },
  { name: "Catalogue", path: "/catalogue", icon: "🗂️" },
  { name: "Authorization", path: "/authorization", icon: "🔒" },
  { name: "Settings", path: "/settings", icon: "⚙️" },
];

export default function Sidebar() {
  return (
    <aside className="sidebar">
      <div className="sidebar-brand">
        <div className="sidebar-logo">AI</div>
        <div>
          <h2 className="sidebar-title">Agentic AI</h2>
          <p className="sidebar-subtitle">Admin Portal</p>
        </div>
      </div>

      <div className="sidebar-section-label">Navigation</div>

      <nav className="sidebar-nav">
        {menuItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            className={({ isActive }) =>
              `sidebar-link ${isActive ? "active" : ""}`
            }
          >
            <span className="sidebar-link-icon">{item.icon}</span>
            <span>{item.name}</span>
          </NavLink>
        ))}
      </nav>

      <div className="sidebar-footer">
        <div className="sidebar-footer-card">
          <div className="sidebar-footer-label">Auth Mode</div>
          <div className="sidebar-footer-value">Local + SSO ready</div>
        </div>
      </div>
    </aside>
  );
}
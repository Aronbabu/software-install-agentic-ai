import { Link, useNavigate } from "react-router-dom";
import { auth } from "../../auth/auth";

export default function Topbar() {
  const navigate = useNavigate();

  const handleLogout = () => {
    auth.signOut();
    navigate("/login", { replace: true });
  };

  return (
    <header className="topbar">
      <div>
        <Link to="/" className="topbar-title">
          Agentic AI Platform
        </Link>
        <div className="topbar-subtitle">Development Environment</div>
      </div>

      <div className="topbar-actions">
        <div className="topbar-chip">
          <span className="topbar-chip-dot" />
          <span>Local auth</span>
        </div>

        <div className="topbar-user">
          <div className="topbar-user-dot" />
          <div>
            <div className="topbar-user-label">Signed in locally</div>
            <div className="topbar-user-subtitle">SSO coming later</div>
          </div>
        </div>

        <button type="button" onClick={handleLogout} className="logout-button">
          Logout
        </button>
      </div>
    </header>
  );
}
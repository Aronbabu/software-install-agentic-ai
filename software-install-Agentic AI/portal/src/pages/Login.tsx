import { useNavigate } from "react-router-dom";
import { auth } from "../auth/auth";

export default function Login() {
  const navigate = useNavigate();
  const isLoggedIn = auth.isAuthenticated();

  const lastLogin = localStorage.getItem("agentic_ai_last_login") || "Not available";

  const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault();

    auth.signIn();
    localStorage.setItem("agentic_ai_last_login", new Date().toLocaleString());
    navigate("/", { replace: true });
  };

  const handleSSOPlaceholder = () => {
    alert("SSO is planned for a future release. For now, use local sign-in.");
  };

  return (
    <div className="login-page">
      <div className="login-card card">
        <div className="login-badge">AI</div>

        <h1 className="page-title" style={{ fontSize: "28px" }}>
          Admin Login
        </h1>
        <p className="page-subtitle">
          Local portal sign-in now, SSO-ready later.
        </p>

        <div className="auth-status-card">
          <div className="auth-status-label">Authentication Status</div>
          <div className={`auth-status-value ${isLoggedIn ? "ok" : "pending"}`}>
            {isLoggedIn ? "Already signed in locally" : "Not signed in"}
          </div>
          <div className="auth-status-note">
            Current mode: local app authentication
          </div>
          <div className="auth-status-note" style={{ marginTop: "10px" }}>
            Last login: {lastLogin}
          </div>
        </div>

        <form className="login-form" onSubmit={handleSubmit}>
          <label className="form-label">
            Username
            <input className="form-input" type="text" placeholder="admin" />
          </label>

          <label className="form-label">
            Password
            <input className="form-input" type="password" placeholder="••••••••" />
          </label>

          <button className="primary-button" type="submit">
            Sign in
          </button>

          <button
            type="button"
            className="secondary-button"
            onClick={handleSSOPlaceholder}
          >
            Sign in with SSO
          </button>
        </form>
      </div>
    </div>
  );
}
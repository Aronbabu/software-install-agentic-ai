import { Outlet } from "react-router-dom";
import Sidebar from "./Sidebar";
import Topbar from "./Topbar";

export default function AdminLayout() {
  return (
    <div
      style={{
        display: "flex",
      }}
    >
      <Sidebar />

      <div
        style={{
          flex: 1,
          background: "#f5f7fa",
          minHeight: "100vh",
        }}
      >
        <Topbar />

        <div
          style={{
            padding: "20px",
          }}
        >
          <Outlet />
        </div>
      </div>
    </div>
  );
}
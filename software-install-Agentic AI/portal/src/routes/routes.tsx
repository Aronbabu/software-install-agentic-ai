import { createBrowserRouter } from "react-router-dom";

import AdminLayout from "../components/layout/AdminLayout";
import Dashboard from "../pages/Dashboard";
import Jobs from "../pages/Jobs";
import JobDetails from "../pages/JobDetails";
import AuditLog from "../pages/AuditLog";
import Login from "../pages/Login";
import Catalogue from "../pages/Catalogue";


import { auth } from "../auth/auth";
import NewJobRequest from "../pages/NewJobRequest";

function ProtectedRoute({ children }: { children: React.ReactNode }) {
  if (!auth.isAuthenticated()) {
    return <Login />;
  }

  return children;
}

export const router = createBrowserRouter([
  {
    path: "/login",
    element: <Login />,
  },
  {
    path: "/",
    element: (
      <ProtectedRoute>
        <AdminLayout />
      </ProtectedRoute>
    ),
    children: [
      {
        index: true,
        element: <Dashboard />,
      },
      {
        path: "jobs",
        element: <Jobs />,
      },
      {
        path: "jobs/:jobId",
        element: <JobDetails />,
      },
      {
        path: "audit-log",
        element: <AuditLog />,
      },
      {
        path: "catalogue",
        element: <Catalogue />,
      },
      {
        path: "jobs/new",
        element: <NewJobRequest />,
      },
    ],
  },
]);
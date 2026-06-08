import { Routes, Route, Navigate } from 'react-router-dom';
import { useAuth } from './context/AuthContext';
import LandingPage from './pages/LandingPage';
import AuthPortalPage from './pages/AuthPortalPage';
import AdminPortalPage from './pages/AdminPortalPage';
import EmployeePortalPage from './pages/EmployeePortalPage';

function ProtectedRoute({ children, role }) {
  const { user } = useAuth();
  if (!user) return <Navigate to="/login" />;
  if (role && user.role !== role) return <Navigate to="/" />;
  return children;
}

export default function App() {
  const { user } = useAuth();
  return (
    <Routes>
      <Route path="/" element={user ? <Navigate to={user.role === 'admin' ? '/dashboard' : '/my-dashboard'} /> : <LandingPage />} />
      <Route element={user ? <Navigate to={user.role === 'admin' ? '/dashboard' : '/my-dashboard'} /> : <AuthPortalPage />}>
        <Route path="/login" element={null} />
        <Route path="/signup" element={null} />
      </Route>

      
      <Route
        element={
          <ProtectedRoute role="admin">
            <AdminPortalPage />
          </ProtectedRoute>
        }
      >
        <Route path="/dashboard" element={null} />
        <Route path="/attendance-admin" element={null} />
        <Route path="/employees" element={null} />
        <Route path="/cameras" element={null} />
        <Route path="/security-alerts" element={null} />
      </Route>

      <Route
        element={
          <ProtectedRoute role="employee">
            <EmployeePortalPage />
          </ProtectedRoute>
        }
      >
        <Route path="/my-dashboard" element={null} />
        <Route path="/attendance" element={null} />
      </Route>
    </Routes>
  );
}

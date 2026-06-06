import { useState, useEffect } from 'react';
import { useLocation } from 'react-router-dom';
import Navbar from '../components/Navbar';

// Import the internal views for admin
import DashboardPage from './DashboardPage';
import AttendanceAdminPage from './AttendanceAdminPage';
import EmployeesPage from './EmployeesPage';
import CamerasPage from './CamerasPage';
import SecurityAlertsPage from './SecurityAlertsPage';

export default function AdminPortalPage() {
  const location = useLocation();
  
  // Track the actual path we should currently display
  const [displayedPath, setDisplayedPath] = useState(location.pathname);
  const [isTransitioning, setIsTransitioning] = useState(false);

  const pathTitles = {
    '/dashboard': 'Dashboard — SafetyWatch',
    '/attendance-admin': 'Attendance Admin — SafetyWatch',
    '/employees': 'Employees — SafetyWatch',
    '/cameras': 'Cameras — SafetyWatch',
    '/security-alerts': 'Security Alerts — SafetyWatch',
  };

  useEffect(() => {

  }, [displayedPath]);

  useEffect(() => {
    // If router URL changes, trigger CSS crossfade
    if (location.pathname !== displayedPath) {
      setIsTransitioning(true);
      const timeout = setTimeout(() => {
        setDisplayedPath(location.pathname);
        setIsTransitioning(false);
      }, 250); // Matches the 0.25s CSS transition
      return () => clearTimeout(timeout);
    }
  }, [location.pathname, displayedPath]);

  // Render the proper component matched to our delayed state transition
  const renderContent = () => {
    switch (displayedPath) {
      case '/dashboard': return <DashboardPage />;
      case '/attendance-admin': return <AttendanceAdminPage />;
      case '/employees': return <EmployeesPage />;
      case '/cameras': return <CamerasPage />;
      case '/security-alerts': return <SecurityAlertsPage />;
      default: return null;
    }
  };

  return (
    <>
      <Navbar variant="dashboard" />
      <main>
        <div className={`tab-content ${isTransitioning ? 'tab-fade-out' : 'tab-fade-in'}`}>
          {renderContent()}
        </div>
      </main>
    </>
  );
}

import { useEffect, useState } from 'react';
import { api } from '../api';

export default function DashboardPage() {

  useEffect(() => {
    document.title = "Dashboard — SafetyWatch";
    fetchDashboard();
  }, []);

  const [stats, setStats] = useState({
    total_employees: '—', present_today: '—',
    active_cameras: '—', active_alerts: '—',
    attendance_rate: '—',
  });
  const [recentAttendance, setRecentAttendance] = useState([]);
  const [recentAlerts, setRecentAlerts] = useState([]);
  const [isLoading, setIsLoading] = useState(true);

  const fetchDashboard = async () => {
    try {
      const res = await api.get('/admin/dashboard');
      setStats(res.data.stats);
      setRecentAttendance(res.data.recent_attendance || []);
      setRecentAlerts(res.data.recent_alerts || []);
    } catch (err) {
      console.error('Failed to load dashboard', err);
    } finally {
      setIsLoading(false);
    }
  };

  const getAttBadge = (status) => {
    if (status === 'present') return 'badge-green';
    if (status === 'late') return 'badge-orange';
    return 'badge-red';
  };

  const getSeverityDot = (severity) => {
    if (severity === 'critical') return 'dot-red';
    if (severity === 'high') return 'dot-orange';
    return 'dot-yellow';
  };

  return (
    <>
      <div className="page-header">
        <h1>Admin Dashboard</h1>
        <p>Overview of your workplace safety system</p>
      </div>

      {/* STAT CARDS */}
      <div className="stats-grid">

        <div className="stat-card">
          <div className="stat-top">
            <div className="stat-icon">
              <svg fill="none" stroke="currentColor" strokeWidth="1.8" viewBox="0 0 24 24">
                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2" /><circle cx="9" cy="7" r="4" />
                <path d="M23 21v-2a4 4 0 0 0-3-3.87M16 3.13a4 4 0 0 1 0 7.75" />
              </svg>
            </div>
          </div>
          <div className="stat-value">{isLoading ? '—' : stats.total_employees}</div>
          <div className="stat-label">Total Employees</div>
        </div>

        <div className="stat-card">
          <div className="stat-top">
            <div className="stat-icon">
              <svg fill="none" stroke="currentColor" strokeWidth="1.8" viewBox="0 0 24 24">
                <polyline points="22 12 18 12 15 21 9 3 6 12 2 12" />
              </svg>
            </div>
            <span className="trend">
              {isLoading ? '' : `${stats.attendance_rate}%`}
            </span>
          </div>
          <div className="stat-value">{isLoading ? '—' : stats.present_today}</div>
          <div className="stat-label">Present Today</div>
        </div>

        <div className="stat-card">
          <div className="stat-top">
            <div className="stat-icon">
              <svg fill="none" stroke="currentColor" strokeWidth="1.8" viewBox="0 0 24 24">
                <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z" />
                <circle cx="12" cy="13" r="4" />
              </svg>
            </div>
            <span className="trend">Active</span>
          </div>
          <div className="stat-value">{isLoading ? '—' : stats.active_cameras}</div>
          <div className="stat-label">Active Cameras</div>
        </div>

        <div className="stat-card">
          <div className="stat-top">
            <div className="stat-icon">
              <svg fill="none" stroke="currentColor" strokeWidth="1.8" viewBox="0 0 24 24">
                <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
                <line x1="12" y1="9" x2="12" y2="13" /><line x1="12" y1="17" x2="12.01" y2="17" />
              </svg>
            </div>
            <span className="trend" style={{ color: stats.active_alerts > 0 ? "var(--red)" : "inherit" }}>
              {stats.active_alerts > 0 ? 'Active' : 'Clear'}
            </span>
          </div>
          <div className="stat-value" style={{ color: stats.active_alerts > 0 ? "var(--red)" : "inherit" }}>
            {isLoading ? '—' : stats.active_alerts}
          </div>
          <div className="stat-label">Security Alerts</div>
        </div>

      </div>

      {/* BOTTOM SECTION */}
      <div className="bottom-grid">

        {/* Recent Attendance */}
        <div className="card">
          <div className="card-title">
            <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
              <circle cx="12" cy="12" r="10" /><polyline points="12 6 12 12 16 14" />
            </svg>
            Recent Attendance
          </div>

          {isLoading ? (
            <div style={{ padding: '1rem', color: 'var(--text-secondary)', fontSize: '14px' }}>Loading...</div>
          ) : recentAttendance.length === 0 ? (
            <div style={{ padding: '1rem', color: 'var(--text-secondary)', fontSize: '14px' }}>No attendance records for today.</div>
          ) : (
            recentAttendance.map((a, i) => (
              <div className="attendance-row" key={i}>
                <div className="att-info">
                  <span className="att-name">{a.employee_name}</span>
                  <span className="att-time">{a.check_in || '—'}</span>
                </div>
                <span className={`badge ${getAttBadge(a.status)}`}>
                  {a.status.charAt(0).toUpperCase() + a.status.slice(1)}
                </span>
              </div>
            ))
          )}
        </div>

        {/* Recent Alerts */}
        <div className="card">
          <div className="card-title">
            <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
              <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z" />
              <line x1="12" y1="9" x2="12" y2="13" /><line x1="12" y1="17" x2="12.01" y2="17" />
            </svg>
            Recent Alerts
          </div>

          {isLoading ? (
            <div style={{ padding: '1rem', color: 'var(--text-secondary)', fontSize: '14px' }}>Loading...</div>
          ) : recentAlerts.length === 0 ? (
            <div style={{ padding: '1rem', color: 'var(--text-secondary)', fontSize: '14px' }}>No active alerts. System is clear ✓</div>
          ) : (
            recentAlerts.map((al, i) => (
              <div className="alert-row" key={i}>
                <span className={`dot ${getSeverityDot(al.severity)}`}></span>
                <div className="alert-body">
                  <div className="alert-title">{al.title}</div>
                  <div className="alert-sub">{al.camera_name}<br />{al.created_at}</div>
                </div>
              </div>
            ))
          )}
        </div>

      </div>
    </>
  );
}


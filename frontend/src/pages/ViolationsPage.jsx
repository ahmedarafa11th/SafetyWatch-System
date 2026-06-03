import { useState, useEffect } from 'react';
import { api } from '../api';

export default function ViolationsPage() {

  useEffect(() => {
    document.title = "Violations — SafetyWatch";
    fetchViolations();
  }, []);

  const [violations, setViolations] = useState([]);
  const [stats, setStats] = useState({ total: 0, high_severity: 0, under_investigation: 0, resolved: 0 });
  const [isLoading, setIsLoading] = useState(true);
  const [cameraFilter, setCameraFilter] = useState('');
  const [cameras, setCameras] = useState([]); // For dynamic camera filter dropdown

  const fetchViolations = async (cameraId = '') => {
    setIsLoading(true);
    try {
      const endpoint = cameraId ? `/admin/violations?camera_id=${cameraId}` : '/admin/violations';
      const res = await api.get(endpoint);
      // ViolationController returns { data:[...], stats:{...}, meta:{...} }
      setViolations(Array.isArray(res.data) ? res.data : (res.data || []));
      if (res.stats) setStats(res.stats);
    } catch (err) {
      console.error('Failed to load violations', err);
    } finally {
      setIsLoading(false);
    }
  };

  // Also fetch cameras for the filter dropdown
  useEffect(() => {
    api.get('/admin/cameras')
      .then(res => setCameras(res.data?.cameras || []))
      .catch(() => {});
  }, []);

  const handleCameraFilterChange = (e) => {
    setCameraFilter(e.target.value);
    fetchViolations(e.target.value);
  };

  const getSeverityBadge = (sev) => {
    const s = sev?.toLowerCase();
    if (s === 'high' || s === 'critical') return 'sev-high';
    if (s === 'medium') return 'sev-medium';
    return 'sev-low';
  };

  const getStatusBadge = (status) => {
    if (status === 'resolved') return 'st-resolved';
    return 'st-investigation';
  };

  const exportToCSV = () => {
    const headers = ['Type', 'Camera', 'Employee', 'Detected At', 'Severity', 'Status'];
    const csvContent = [
      headers.join(','),
      ...violations.map(r =>
        `"${r.type}","${r.camera?.name || '—'}","${r.employee?.user?.name || 'Unknown'}","${r.detected_at || '—'}","${r.severity}","${r.status}"`
      )
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.setAttribute('download', 'violation-logs.csv');
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const formatDate = (d) => {
    if (!d) return '—';
    return new Date(d).toLocaleString();
  };

  return (
    <>
      <div className="page-header">
        <div className="page-title">
          <h1>Violation Logs</h1>
          <p>Monitor security violations and incidents</p>
        </div>
        <div className="page-actions">
          <div className="filter-group">
            <select
              id="cameraFilter"
              className="btn btn-outline"
              style={{ padding: "8px 12px", cursor: "pointer" }}
              value={cameraFilter}
              onChange={handleCameraFilterChange}
            >
              <option value="">All Cameras</option>
              {cameras.map(cam => (
                <option key={cam.id} value={cam.id}>{cam.name}</option>
              ))}
            </select>
          </div>
          <button className="btn btn-primary" onClick={exportToCSV} disabled={violations.length === 0}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/><polyline points="7 10 12 15 17 10"/><line x1="12" y1="15" x2="12" y2="3"/>
            </svg>
            Export Report
          </button>
        </div>
      </div>

      {/* STATS */}
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-value red">{isLoading ? '—' : stats.total}</div>
          <div className="stat-label">Total Violations</div>
        </div>
        <div className="stat-card">
          <div className="stat-value orange">{isLoading ? '—' : stats.high_severity}</div>
          <div className="stat-label">High Severity</div>
        </div>
        <div className="stat-card">
          <div className="stat-value blue">{isLoading ? '—' : stats.under_investigation}</div>
          <div className="stat-label">Under Investigation</div>
        </div>
        <div className="stat-card">
          <div className="stat-value green">{isLoading ? '—' : stats.resolved}</div>
          <div className="stat-label">Resolved</div>
        </div>
      </div>

      {/* TABLE */}
      {isLoading ? (
        <div style={{ padding: '2rem', textAlign: 'center', color: 'var(--text-secondary)' }}>Loading violations...</div>
      ) : (
        <div className="table-card">
          <table>
            <thead>
              <tr>
                <th>Type</th>
                <th>Camera</th>
                <th>Employee</th>
                <th>Detected At</th>
                <th>Severity</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {violations.length === 0 ? (
                <tr>
                  <td colSpan={6} style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '1.5rem' }}>
                    No violations recorded.
                  </td>
                </tr>
              ) : violations.map((val, idx) => (
                <tr key={val.id || idx}>
                  <td>
                    <div className="type-cell">
                      <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                        <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/>
                        <line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>
                      </svg>
                      {val.type}
                    </div>
                  </td>
                  <td>{val.camera?.name || '—'}</td>
                  <td>{val.employee?.user?.name || 'Unknown'}</td>
                  <td className="mono">{formatDate(val.detected_at)}</td>
                  <td><span className={`badge ${getSeverityBadge(val.severity)}`}>{val.severity}</span></td>
                  <td><span className={`badge ${getStatusBadge(val.status)}`}>{val.status}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </>
  );
}

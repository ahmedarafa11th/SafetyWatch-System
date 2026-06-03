import { useState, useEffect } from 'react';
import { api } from '../api';

export default function SecurityAlertsPage() {

  useEffect(() => {
    document.title = "Security Alerts — SafetyWatch";
    fetchAlerts();
  }, []);

  const [alerts, setAlerts] = useState([]);
  const [stats, setStats] = useState({ active: 0, critical: 0, unread: 0, resolved_today: 0, avg_confidence: 0 });
  const [isLoading, setIsLoading] = useState(true);
  const [actioningId, setActioningId] = useState(null);

  const fetchAlerts = async () => {
    setIsLoading(true);
    try {
      const res = await api.get('/admin/alerts');
      setAlerts(res.data.alerts.data || res.data.alerts || []);
      setStats(res.data.stats);
    } catch (err) {
      console.error('Failed to load alerts', err);
    } finally {
      setIsLoading(false);
    }
  };

  const handleResolve = async (id) => {
    setActioningId(id);
    try {
      await api.post(`/admin/alerts/${id}/resolve`, {});
      fetchAlerts();
    } catch (err) {
      alert(err.message || 'Failed to resolve alert');
    } finally {
      setActioningId(null);
    }
  };

  const handleDismiss = async (id) => {
    setActioningId(id);
    try {
      await api.post(`/admin/alerts/${id}/dismiss`, {});
      fetchAlerts();
    } catch (err) {
      alert(err.message || 'Failed to dismiss alert');
    } finally {
      setActioningId(null);
    }
  };

  const handleMarkAllRead = async () => {
    try {
      await api.post('/admin/alerts/mark-all-read', {});
      fetchAlerts();
    } catch (err) {
      alert(err.message || 'Failed to mark all as read');
    }
  };

  const getSeverityClass = (sev) => {
    if (sev === 'critical') return 'badge-critical';
    if (sev === 'high') return 'badge-high';
    if (sev === 'medium') return 'badge-medium';
    return 'badge-low';
  };

  const getStatusClass = (status) => {
    if (status === 'active') return 'badge-active';
    if (status === 'resolved') return 'badge-resolved';
    return 'badge-dismissed';
  };

  const formatDate = (dateStr) => {
    if (!dateStr) return '—';
    return new Date(dateStr).toLocaleString();
  };

  return (
    <>
      <div className="page-header">
        <div className="page-title">
          <h1>Security Alerts</h1>
          <p>Real-time violence detection and security monitoring</p>
        </div>
        <button className="btn-mark" onClick={handleMarkAllRead}>
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"/><path d="M13.73 21a2 2 0 0 1-3.46 0"/>
          </svg>
          Mark All as Read
        </button>
      </div>

      {/* STATS */}
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-value red">{isLoading ? '—' : stats.active}</div>
          <div className="stat-label">Active Alerts</div>
        </div>
        <div className="stat-card">
          <div className="stat-value orange">{isLoading ? '—' : stats.critical}</div>
          <div className="stat-label">Critical</div>
        </div>
        <div className="stat-card">
          <div className="stat-value blue">{isLoading ? '—' : stats.resolved_today}</div>
          <div className="stat-label">Resolved Today</div>
        </div>
        <div className="stat-card">
          <div className="stat-value dark">{isLoading ? '—' : `${stats.avg_confidence}%`}</div>
          <div className="stat-label">Avg. Confidence</div>
        </div>
      </div>

      {/* ALERT CARDS */}
      {isLoading ? (
        <div style={{ padding: '2rem', textAlign: 'center', color: 'var(--text-secondary)' }}>Loading alerts...</div>
      ) : alerts.length === 0 ? (
        <div style={{ padding: '2rem', textAlign: 'center', color: 'var(--text-secondary)' }}>No alerts found. System is clear ✓</div>
      ) : (
        <div className="alerts-list">
          {alerts.map((alert) => (
            <div className="alert-card" key={alert.id}>
              <div className={`alert-icon ${alert.severity}`}>
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"/><line x1="12" y1="9" x2="12" y2="13"/><line x1="12" y1="17" x2="12.01" y2="17"/>
                </svg>
              </div>
              <div className="alert-body">
                <div className="alert-title-row">
                  <span className="alert-title">{alert.title}</span>
                  <span className={`badge badge-${alert.severity}`}>
                    {alert.severity.charAt(0).toUpperCase() + alert.severity.slice(1)}
                  </span>
                  <span className={`badge badge-${alert.status}`}>
                    {alert.status.charAt(0).toUpperCase() + alert.status.slice(1)}
                  </span>
                </div>
                <p className="alert-desc">{alert.description || '—'}</p>
                <div className="alert-meta">
                  <span className="meta-item">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M15 10l-4 4l6 6l4-16l-18 7l4 2l2 6l3-4"/></svg>
                    {alert.camera?.name || 'Unknown Camera'}
                  </span>
                  <span className="meta-item">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/></svg>
                    {formatDate(alert.created_at)}
                  </span>
                  {alert.confidence && (
                    <span className="meta-item confidence">✓ Confidence: {alert.confidence}%</span>
                  )}
                </div>
              </div>
              {alert.status === 'active' && (
                <div className="alert-actions">
                  <button
                    className="btn-action btn-resolve"
                    onClick={() => handleResolve(alert.id)}
                    disabled={actioningId === alert.id}
                  >
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polyline points="20 6 9 17 4 12"/></svg>
                    Resolve
                  </button>
                  <button
                    className="btn-action btn-dismiss"
                    onClick={() => handleDismiss(alert.id)}
                    disabled={actioningId === alert.id}
                  >
                    <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><line x1="15" y1="9" x2="9" y2="15"/><line x1="9" y1="9" x2="15" y2="15"/></svg>
                    Dismiss
                  </button>
                </div>
              )}
            </div>
          ))}
        </div>
      )}
    </>
  );
}


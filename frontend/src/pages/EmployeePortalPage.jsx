import { useState, useEffect } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import Navbar from '../components/Navbar';
import { useAuth } from '../context/AuthContext';
import { api } from '../api';

/* ─── helpers ──────────────────────────────────────────────────── */
const fmtTime = (t) => {
  if (!t) return '—';
  const [h, m] = t.split(':');
  const hr = parseInt(h);
  return `${hr % 12 || 12}:${m} ${hr < 12 ? 'AM' : 'PM'}`;
};

const formatDate = (dateString) => {
  if (!dateString || dateString === '-') return '—';
  const d = new Date(dateString);
  return d.toLocaleDateString(undefined, { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' });
};

const badgeClass = (s) => {
  if (s === 'present') return 'badge-green';
  if (s === 'late')    return 'badge-orange';
  if (s === 'absent')  return 'badge-red';
  return 'badge-medium';
};

/* ─── DASHBOARD CONTENT ───────────────────────────────────────── */
function DashboardContent() {
  const { user } = useAuth();
  const [stats,   setStats]   = useState({ days_present: 0, days_late: 0, days_absent: 0, total_hours: '0h' });
  const [recent,  setRecent]  = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/employee/attendance')
      .then(res => {
        const d = res.data;
        if (d.stats)   setStats(d.stats);
        if (d.records) setRecent(d.records.slice(0, 5));
      })
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  const total = stats.days_present + stats.days_late + stats.days_absent;
  const rate  = total > 0 ? Math.round(((stats.days_present + stats.days_late) / total) * 100) : 0;

  return (
    <>
      <div className="page-header">
        <div className="page-title">
          <h1>My Dashboard</h1>
          <p>Welcome back, {user?.name || 'Employee'}</p>
        </div>
      </div>

      <div className="stats-grid">
        {[
          { label: 'Days Present',    value: stats.days_present, color: 'blue'   },
          { label: 'Days Late',       value: stats.days_late,    color: 'orange' },
          { label: 'Days Absent',     value: stats.days_absent,  color: 'red'    },
          { label: 'Attendance Rate', value: `${rate}%`,         color: 'green'  },
        ].map(s => (
          <div className="stat-card" key={s.label}>
            <div className={`stat-value ${s.color}`}>{loading ? '—' : s.value}</div>
            <div className="stat-label">{s.label}</div>
          </div>
        ))}
      </div>

      <div className="table-card">
        <div style={{ padding: '1rem 1.25rem', fontWeight: 600, fontSize: '0.9rem' }}>Recent Attendance</div>
        {loading ? (
          <div style={{ padding: '1rem', color: 'var(--text-secondary)' }}>Loading...</div>
        ) : recent.length === 0 ? (
          <div style={{ padding: '1rem', color: 'var(--text-secondary)' }}>No attendance records yet.</div>
        ) : (
          <table>
            <thead>
              <tr><th>Date</th><th>Check In</th><th>Check Out</th><th>Hours</th><th>Status</th></tr>
            </thead>
            <tbody>
              {recent.map((r, i) => (
                <tr key={i}>
                  <td>{formatDate(r.date)}</td>
                  <td>{fmtTime(r.check_in)}</td>
                  <td>{fmtTime(r.check_out)}</td>
                  <td>{r.total_hours}h</td>
                  <td><span className={`badge ${badgeClass(r.status)}`}>{r.status}</span></td>
                </tr>
              ))}
            </tbody>
          </table>
        )}
      </div>
    </>
  );
}

/* ─── ATTENDANCE CONTENT ──────────────────────────────────────── */
function AttendanceContent() {
  const [records,     setRecords]     = useState([]);
  const [stats,       setStats]       = useState({ days_present: 0, days_late: 0, days_absent: 0, total_hours: '0h' });
  const [loading,     setLoading]     = useState(true);
  const [filterMonth, setFilterMonth] = useState('');
  const [tempMonth,   setTempMonth]   = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);

  const fetchData = async (month = '') => {
    setLoading(true);
    try {
      const ep  = month ? `/employee/attendance?month=${month}` : '/employee/attendance';
      const res = await api.get(ep);
      const d   = res.data;
      setRecords(d.records || []);
      if (d.stats) setStats(d.stats);
    } catch (e) { console.error(e); }
    finally { setLoading(false); }
  };

  useEffect(() => { fetchData(); }, []);

  const applyFilter = () => { setFilterMonth(tempMonth); fetchData(tempMonth); setIsModalOpen(false); };
  const clearFilter = () => { setTempMonth(''); setFilterMonth(''); fetchData(''); setIsModalOpen(false); };

  const fmtBtn = (v) => {
    if (!v) return 'Filter by Month';
    const [yr, mo] = v.split('-');
    return `${['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][+mo - 1]} ${yr}`;
  };

  const exportCSV = () => {
    const rows = [
      ['Date', 'Check In', 'Check Out', 'Hours', 'Status'],
      ...records.map(r => [formatDate(r.date), fmtTime(r.check_in), fmtTime(r.check_out), r.total_hours + 'h', r.status]),
    ];
    const csv  = rows.map(r => r.map(c => `"${c}"`).join(',')).join('\n');
    const blob = new Blob([csv], { type: 'text/csv' });
    const a    = document.createElement('a');
    a.href     = URL.createObjectURL(blob);
    a.download = 'attendance.csv';
    a.click();
  };

  return (
    <>
      <div className="page-header">
        <div className="page-title">
          <h1>My Attendance Logs</h1>
          <p>View your complete attendance history</p>
        </div>
        <div className="page-actions">
          <button className="btn btn-outline" onClick={() => setIsModalOpen(true)}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <rect x="3" y="4" width="18" height="18" rx="2" ry="2" /><line x1="16" y1="2" x2="16" y2="6" /><line x1="8" y1="2" x2="8" y2="6" /><line x1="3" y1="10" x2="21" y2="10" />
            </svg>
            <span>{fmtBtn(filterMonth)}</span>
          </button>
          <button className="btn btn-primary" onClick={exportCSV}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" /><polyline points="7 10 12 15 17 10" /><line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            Export
          </button>
        </div>
      </div>

      {/* Month Picker Modal */}
      <div className={`modal-overlay ${isModalOpen ? 'open' : ''}`}>
        <div className="modal-box">
          <div className="modal-header">
            <h3>Select Month</h3>
            <button className="modal-close" onClick={() => setIsModalOpen(false)}>&times;</button>
          </div>
          <div className="modal-body">
            <input type="month" className="month-input" value={tempMonth} onChange={e => setTempMonth(e.target.value)} />
            <div className="modal-actions">
              <button className="btn btn-outline" onClick={clearFilter}>Clear</button>
              <button className="btn btn-primary" onClick={applyFilter}>Apply</button>
            </div>
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="stats-grid">
        <div className="stat-card"><div className="stat-value blue">{stats.days_present}</div><div className="stat-label">Days Present</div></div>
        <div className="stat-card"><div className="stat-value orange">{stats.days_late}</div><div className="stat-label">Days Late</div></div>
        <div className="stat-card"><div className="stat-value red">{stats.days_absent}</div><div className="stat-label">Days Absent</div></div>
        <div className="stat-card"><div className="stat-value green">{stats.total_hours}</div><div className="stat-label">Total Hours</div></div>
      </div>

      {/* Table */}
      <div className="table-card">
        <table>
          <thead><tr><th>Date</th><th>Check In</th><th>Check Out</th><th>Total Hours</th><th>Status</th></tr></thead>
          <tbody>
            {loading ? (
              <tr><td colSpan={5} style={{ textAlign: 'center', padding: '1.5rem', color: 'var(--text-secondary)' }}>Loading...</td></tr>
            ) : records.length === 0 ? (
              <tr><td colSpan={5} style={{ textAlign: 'center', padding: '1.5rem', color: 'var(--text-secondary)' }}>No records found.</td></tr>
            ) : records.map((r, i) => (
              <tr key={i}>
                <td>{formatDate(r.date)}</td>
                <td>{fmtTime(r.check_in)}</td>
                <td>{fmtTime(r.check_out)}</td>
                <td>{r.total_hours}h</td>
                <td><span className={`badge ${badgeClass(r.status)}`}>{r.status}</span></td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </>
  );
}

/* ─── PORTAL (COMBINED PAGE) ──────────────────────────────────── */
export default function EmployeePortalPage() {
  const location = useLocation();
  const navigate = useNavigate();

  const activeTab = location.pathname === '/attendance' ? 'attendance' : 'dashboard';
  const [displayedTab,    setDisplayedTab]    = useState(activeTab);
  const [isTransitioning, setIsTransitioning] = useState(false);

  useEffect(() => {

  }, [displayedTab]);

  useEffect(() => {
    if (activeTab !== displayedTab) {
      setIsTransitioning(true);
      const t = setTimeout(() => { setDisplayedTab(activeTab); setIsTransitioning(false); }, 250);
      return () => clearTimeout(t);
    }
  }, [activeTab, displayedTab]);

  return (
    <>
      <Navbar variant="dashboard" />
      <main>
        <div className={`tab-content ${isTransitioning ? 'tab-fade-out' : 'tab-fade-in'}`}>
          {displayedTab === 'dashboard' ? <DashboardContent /> : <AttendanceContent />}
        </div>
      </main>
    </>
  );
}

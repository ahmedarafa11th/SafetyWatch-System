import { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { api } from '../api';
import FaceScanModal from '../components/FaceScanModal';

export default function AttendanceAdminPage() {

  useEffect(() => {

    fetchAttendance('');
  }, []);

  const [logs, setLogs] = useState([]);
  const [todayStats, setTodayStats] = useState({ present: 0, late: 0, absent: 0, attendance_rate: 0 });
  const [isLoading, setIsLoading] = useState(true);
  const [filterMonth, setFilterMonth] = useState('');
  const [tempMonth, setTempMonth] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);
  const [isFaceScanOpen, setIsFaceScanOpen] = useState(false);
  const [faceScanAction, setFaceScanAction] = useState('check_in');

  const fetchAttendance = async (month) => {
    setIsLoading(true);
    try {
      const endpoint = month ? `/admin/attendance?month=${month}` : '/admin/attendance';
      const res = await api.get(endpoint);
      // AttendanceController index() returns: { data:[...], stats:{...}, meta:{...} }
      setLogs(Array.isArray(res.data) ? res.data : (res.data || []));
      if (res.stats) setTodayStats(res.stats);
    } catch (err) {
      console.error('Failed to load attendance', err);
    } finally {
      setIsLoading(false);
    }
  };

  const getStatusBadge = (status) => {
    if (status === 'present') return 'badge-green';
    if (status === 'late') return 'badge-orange';
    return 'badge-red';
  };

  const formatDate = (dateString) => {
    if (!dateString) return '—';
    const d = new Date(dateString);
    return d.toLocaleDateString(undefined, { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' });
  };

  const applyFilter = () => {
    setFilterMonth(tempMonth);
    setIsModalOpen(false);
    fetchAttendance(tempMonth);
  };

  const clearFilter = () => {
    setTempMonth('');
    setFilterMonth('');
    setIsModalOpen(false);
    fetchAttendance('');
  };

  const exportToCSV = () => {
    const headers = ['Employee Name', 'Date', 'Check In', 'Check Out', 'Total Hours', 'Status'];
    const csvContent = [
      headers.join(','),
      ...logs.map(r => {
        const name = r.employee?.user?.name || '—';
        return `"${name}","${formatDate(r.date)}","${r.check_in || '—'}","${r.check_out || '—'}","${r.total_hours || '—'}","${r.status}"`;
      })
    ].join('\n');

    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.setAttribute('download', 'attendance-admin-logs.csv');
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  const formatMonthBtn = (val) => {
    if (!val) return 'Filter by Date';
    const [year, month] = val.split('-');
    const monthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return `${monthNames[parseInt(month)-1]} ${year}`;
  };

  return (
    <>
      <div className="page-header">
        <div className="page-title">
          <h1>Attendance Logs</h1>
          <p>Monitor company-wide attendance and shifts</p>
        </div>
        <div className="page-actions">
          <button className="btn btn-primary" onClick={() => { setFaceScanAction('check_in'); setIsFaceScanOpen(true); }} style={{ background: 'var(--green)', borderColor: 'var(--green)' }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" style={{ marginRight: '6px' }}>
              <path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z" />
              <circle cx="12" cy="13" r="3" />
            </svg>
            Check In
          </button>
          <button className="btn btn-primary" onClick={() => { setFaceScanAction('check_out'); setIsFaceScanOpen(true); }} style={{ background: 'var(--red)', borderColor: 'var(--red)' }}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" style={{ marginRight: '6px' }}>
              <path d="M14.5 4h-5L7 7H4a2 2 0 0 0-2 2v9a2 2 0 0 0 2 2h16a2 2 0 0 0 2-2V9a2 2 0 0 0-2-2h-3l-2.5-3z" />
              <circle cx="12" cy="13" r="3" />
            </svg>
            Check Out
          </button>
          <button className="btn btn-primary" onClick={() => setIsModalOpen(true)}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <rect x="3" y="4" width="18" height="18" rx="2" ry="2" /><line x1="16" y1="2" x2="16" y2="6" /><line x1="8" y1="2" x2="8" y2="6" /><line x1="3" y1="10" x2="21" y2="10" />
            </svg>
            <span>{formatMonthBtn(filterMonth)}</span>
          </button>
          <button className="btn btn-primary" onClick={exportToCSV} disabled={logs.length === 0}>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
              <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" /><polyline points="7 10 12 15 17 10" /><line x1="12" y1="15" x2="12" y2="3" />
            </svg>
            Export
          </button>
        </div>
      </div>

      {/* TODAY STATS */}
      <div className="stats-grid">
        <div className="stat-card">
          <div className="stat-value green">{todayStats.present}</div>
          <div className="stat-label">Present Today</div>
        </div>
        <div className="stat-card">
          <div className="stat-value orange">{todayStats.late}</div>
          <div className="stat-label">Late Today</div>
        </div>
        <div className="stat-card">
          <div className="stat-value red">{todayStats.absent}</div>
          <div className="stat-label">Absent Today</div>
        </div>
        <div className="stat-card">
          <div className="stat-value dark">{todayStats.attendance_rate}%</div>
          <div className="stat-label">Attendance Rate</div>
        </div>
      </div>

      {/* MONTH PICKER MODAL */}
      {isModalOpen && createPortal(
        <div className="modal-overlay open" onClick={(e) => { if (e.target === e.currentTarget) setIsModalOpen(false); }}>
          <div className="modal-box">
            <div className="modal-header">
              <h3>Select Month</h3>
              <button className="modal-close" onClick={() => setIsModalOpen(false)}>&times;</button>
            </div>
            <div className="modal-body">
              <input
                type="month"
                className="month-input"
                value={tempMonth}
                onChange={(e) => setTempMonth(e.target.value)}
              />
              <div className="modal-actions">
                <button className="btn btn-outline" onClick={clearFilter}>Clear Filter</button>
                <button className="btn btn-primary" onClick={applyFilter}>Apply</button>
              </div>
            </div>
          </div>
        </div>,
        document.body
      )}

      {/* TABLE */}
      {isLoading ? (
        <div style={{ padding: '2rem', textAlign: 'center', color: 'var(--text-secondary)' }}>Loading attendance records...</div>
      ) : (
        <div className="table-card">
          <table>
            <thead>
              <tr>
                <th>Employee Name</th>
                <th>Date</th>
                <th>Check In</th>
                <th>Check Out</th>
                <th>Total Hours</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {logs.length === 0 ? (
                <tr>
                  <td colSpan={6} style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '1.5rem' }}>
                    No attendance records found.
                  </td>
                </tr>
              ) : logs.map((log, idx) => (
                <tr key={log.id || idx}>
                  <td><strong>{log.employee?.user?.name || '—'}</strong></td>
                  <td className="mono">{formatDate(log.date)}</td>
                  <td className="mono">{log.check_in || '—'}</td>
                  <td className="mono">{log.check_out || '—'}</td>
                  <td className="mono">{log.total_hours ? `${log.total_hours}h` : '—'}</td>
                  <td>
                    <span className={`badge ${getStatusBadge(log.status)}`}>
                      {log.status.charAt(0).toUpperCase() + log.status.slice(1)}
                    </span>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* FACE SCAN MODAL */}
      <FaceScanModal 
        isOpen={isFaceScanOpen} 
        actionType={faceScanAction}
        onClose={() => setIsFaceScanOpen(false)} 
        onLogSuccess={(msg) => {
          alert(msg);
          fetchAttendance(''); // Refresh list automatically
        }}
      />
    </>
  );
}

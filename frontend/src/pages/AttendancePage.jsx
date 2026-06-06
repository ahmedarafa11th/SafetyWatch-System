import { useState, useEffect } from 'react';
import Navbar from '../components/Navbar';

const initialLogs = [
  { date: "2026-02-01", in: "08:45 AM", out: "05:30 PM", hours: 8.75, status: "Present" },
  { date: "2026-01-31", in: "08:50 AM", out: "05:25 PM", hours: 8.58, status: "Present" },
  { date: "2026-01-30", in: "08:35 AM", out: "05:40 PM", hours: 9.08, status: "Present" },
  { date: "2026-01-29", in: "08:55 AM", out: "05:35 PM", hours: 8.67, status: "Present" },
  { date: "2026-01-28", in: "09:10 AM", out: "05:45 PM", hours: 8.58, status: "Late"    },
  { date: "2026-01-27", in: "08:40 AM", out: "05:20 PM", hours: 8.67, status: "Present" },
  { date: "2026-01-26", in: "08:30 AM", out: "05:15 PM", hours: 8.75, status: "Present" },
  { date: "2026-01-25", in: "-",        out: "-",        hours: 0,    status: "Absent"  },
  { date: "2026-01-24", in: "08:45 AM", out: "05:30 PM", hours: 8.75, status: "Present" },
  { date: "2026-01-23", in: "08:55 AM", out: "05:40 PM", hours: 8.75, status: "Present" },
  { date: "2026-01-22", in: "08:25 AM", out: "05:10 PM", hours: 8.75, status: "Present" },
  { date: "2026-01-21", in: "09:05 AM", out: "05:50 PM", hours: 8.75, status: "Late"    },
];

export default function AttendancePage() {

  useEffect(() => {

  }, []);
  const [filterMonth, setFilterMonth] = useState('');
  const [tempMonth, setTempMonth] = useState('');
  const [isModalOpen, setIsModalOpen] = useState(false);

  const filteredLogs = initialLogs.filter(log => 
    !filterMonth || log.date.startsWith(filterMonth)
  );

  const stats = {
    present: filteredLogs.filter(l => l.status === 'Present').length,
    late: filteredLogs.filter(l => l.status === 'Late').length,
    absent: filteredLogs.filter(l => l.status === 'Absent').length,
    totalHours: filteredLogs.reduce((acc, l) => acc + l.hours, 0)
  };

  const getStatusBadge = (status) => {
    if (status === 'Present') return 'badge-present';
    if (status === 'Late') return 'badge-late';
    return 'badge-absent';
  };

  const formatDate = (dateString) => {
    if (!dateString) return '—';
    const d = new Date(dateString);
    return d.toLocaleDateString(undefined, { weekday: 'short', year: 'numeric', month: 'short', day: 'numeric' });
  };

  const applyFilter = () => {
    setFilterMonth(tempMonth);
    setIsModalOpen(false);
  };

  const clearFilter = () => {
    setTempMonth('');
    setFilterMonth('');
    setIsModalOpen(false);
  };

  const formatMonthBtn = (val) => {
    if (!val) return 'Filter by Date';
    const [year, month] = val.split('-');
    const monthNames = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    return `${monthNames[parseInt(month)-1]} ${year}`;
  };

  const exportToCSV = () => {
    const headers = ['Date', 'Check In', 'Check Out', 'Total Hours', 'Status'];
    const csvContent = [
      headers.join(','),
      ...filteredLogs.map(r => `"${formatDate(r.date)}","${r.in}","${r.out}","${r.hours}h","${r.status}"`)
    ].join('\n');
    
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const link = document.createElement('a');
    link.href = URL.createObjectURL(blob);
    link.setAttribute('download', 'my-attendance-logs.csv');
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  return (
    <>
      <Navbar variant="dashboard" />
      <main>
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
              <span>{formatMonthBtn(filterMonth)}</span>
            </button>
            <button className="btn btn-primary" onClick={exportToCSV}>
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4" /><polyline points="7 10 12 15 17 10" /><line x1="12" y1="15" x2="12" y2="3" />
              </svg>
              Export
            </button>
          </div>
        </div>

        {/* MONTH PICKER MODAL */}
        <div className={`modal-overlay ${isModalOpen ? 'open' : ''}`}>
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
        </div>

        {/* STATS */}
        <div className="stats-grid">
          <div className="stat-card">
            <div className="stat-value blue">{stats.present}</div>
            <div className="stat-label">Days Present</div>
          </div>
          <div className="stat-card">
            <div className="stat-value orange">{stats.late}</div>
            <div className="stat-label">Days Late</div>
          </div>
          <div className="stat-card">
            <div className="stat-value red">{stats.absent}</div>
            <div className="stat-label">Days Absent</div>
          </div>
          <div className="stat-card">
            <div className="stat-value green">{stats.totalHours.toFixed(1)}h</div>
            <div className="stat-label">Total Hours</div>
          </div>
        </div>

        {/* TABLE */}
        <div className="table-card">
          <table>
            <thead>
              <tr>
                <th>Date</th>
                <th>Check In</th>
                <th>Check Out</th>
                <th>Total Hours</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              {filteredLogs.map((log, idx) => {
                const isDash = log.in === "-";
                return (
                  <tr key={idx}>
                    <td className="date-cell">{formatDate(log.date)}</td>
                    <td className={isDash ? 'dash-cell' : ''}>{log.in}</td>
                    <td className={isDash ? 'dash-cell' : ''}>{log.out}</td>
                    <td>{log.hours}h</td>
                    <td><span className={`badge ${getStatusBadge(log.status)}`}>{log.status}</span></td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </main>
    </>
  );
}

import { useEffect } from 'react';
import Navbar from '../components/Navbar';
import { useAuth } from '../context/AuthContext';

export default function MyDashboardPage() {

  useEffect(() => {

  }, []);
  const { user } = useAuth();

  return (
    <>
      <Navbar variant="dashboard" />
      <main>
        <div className="page-header">
          <h1>My Dashboard</h1>
          <p>Track your attendance and work statistics</p>
        </div>

        {/* STAT CARDS */}
        <div className="stats-grid">
          <div className="stat-card">
            <div className="stat-icon">
              <svg fill="none" stroke="currentColor" strokeWidth="1.7" viewBox="0 0 24 24">
                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                <line x1="16" y1="2" x2="16" y2="6"/>
                <line x1="8" y1="2" x2="8" y2="6"/>
                <line x1="3" y1="10" x2="21" y2="10"/>
              </svg>
            </div>
            <div className="stat-value">22</div>
            <div className="stat-label">Days Present</div>
          </div>

          <div className="stat-card">
            <div className="stat-icon red">
              <svg fill="none" stroke="currentColor" strokeWidth="1.7" viewBox="0 0 24 24">
                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                <line x1="16" y1="2" x2="16" y2="6"/>
                <line x1="8" y1="2" x2="8" y2="6"/>
                <line x1="3" y1="10" x2="21" y2="10"/>
              </svg>
            </div>
            <div className="stat-value">1</div>
            <div className="stat-label">Days Absent</div>
          </div>

          <div className="stat-card">
            <div className="stat-icon">
              <svg fill="none" stroke="currentColor" strokeWidth="1.7" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10"/>
                <polyline points="12 6 12 12 16 14"/>
              </svg>
            </div>
            <div className="stat-value">8.5</div>
            <div className="stat-label">Average Hours</div>
          </div>

          <div className="stat-card">
            <div className="stat-icon green">
              <svg fill="none" stroke="currentColor" strokeWidth="1.7" viewBox="0 0 24 24">
                <polyline points="23 6 13.5 15.5 8.5 10.5 1 18"/>
                <polyline points="17 6 23 6 23 12"/>
              </svg>
            </div>
            <div className="stat-value">95.6%</div>
            <div className="stat-label">Attendance Rate</div>
          </div>
        </div>

        {/* BOTTOM SECTION */}
        <div className="bottom-grid">
          {/* Recent Attendance Table */}
          <div className="card">
            <div className="card-title">
              <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10"/><polyline points="12 6 12 12 16 14"/>
              </svg>
              Recent Attendance
            </div>

            <table>
              <thead>
                <tr>
                  <th>Date</th>
                  <th>Check In</th>
                  <th>Check Out</th>
                  <th>Hours</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>2026-02-01</td>
                  <td>08:45 AM</td>
                  <td>05:30 PM</td>
                  <td>8.75h</td>
                  <td><span className="badge badge-green">Present</span></td>
                </tr>
                <tr>
                  <td>2026-01-31</td>
                  <td>08:50 AM</td>
                  <td>05:25 PM</td>
                  <td>8.58h</td>
                  <td><span className="badge badge-green">Present</span></td>
                </tr>
                <tr>
                  <td>2026-01-30</td>
                  <td>08:35 AM</td>
                  <td>05:40 PM</td>
                  <td>9.08h</td>
                  <td><span className="badge badge-green">Present</span></td>
                </tr>
                <tr>
                  <td>2026-01-29</td>
                  <td>08:55 AM</td>
                  <td>05:35 PM</td>
                  <td>8.67h</td>
                  <td><span className="badge badge-green">Present</span></td>
                </tr>
                <tr>
                  <td>2026-01-28</td>
                  <td>09:10 AM</td>
                  <td>05:45 PM</td>
                  <td>8.58h</td>
                  <td><span className="badge badge-orange">Late</span></td>
                </tr>
              </tbody>
            </table>
          </div>

          {/* This Month */}
          <div className="card month-card">
            <div className="card-title">
              <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                <circle cx="12" cy="8" r="4"/>
                <path d="M6 20v-2a6 6 0 0 1 12 0v2"/>
              </svg>
              This Month
            </div>

            <div className="month-section">
              <div className="month-row">
                <span className="month-label">Attendance</span>
                <span className="month-pct">95.6%</span>
              </div>
              <div className="progress-bar">
                <div className="progress-fill" style={{ width: '95.6%' }}></div>
              </div>
            </div>

            <div className="month-section">
              <div className="month-row">
                <span className="month-label">Punctuality</span>
                <span className="month-pct">78.3%</span>
              </div>
              <div className="progress-bar">
                <div className="progress-fill" style={{ width: '78.3%' }}></div>
              </div>
            </div>

            <div className="month-divider"></div>

            <div className="month-section">
              <div className="month-stat-label">Total Work Hours</div>
              <div className="month-stat-value">186.5h</div>
            </div>

            <div className="month-divider"></div>

            <div>
              <div className="month-stat-label">Days Worked</div>
              <div className="month-stat-value">22 days</div>
            </div>
          </div>
        </div>
      </main>
    </>
  );
}

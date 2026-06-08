import { Link, useLocation } from 'react-router-dom';
import ThemeToggle from './ThemeToggle';
import { useAuth } from '../context/AuthContext';
import logoLight from '../assets/logo_v2.png';
import logoDark from '../assets/logo_v2_dark.png';
export default function Navbar({ variant = 'landing' }) {
  const location = useLocation();
  const { user, logout } = useAuth();

  const Logo = () => (
    <Link to="/" className="logo" style={{ display: 'flex', alignItems: 'center', gap: '8px', textDecoration: 'none', fontSize: '22px', fontWeight: 'bold' }}>
      <img src={logoLight} alt="SafetyWatch Logo" className="logo-light-img" style={{ width: '28px', height: '28px', objectFit: 'contain' }} />
      <img src={logoDark} alt="SafetyWatch Logo" className="logo-dark-img" style={{ width: '28px', height: '28px', objectFit: 'contain', }} />
      <span>
        <span className="logo-text-1">Safety</span><span className="logo-text-2">Watch</span>
      </span>
    </Link>
  );

  // Landing page navbar with anchor links
  if (variant === 'landing') {
    return (
      <nav>
        <Logo />
        <ul>
          <li><a href="#home">Home</a></li>
          <li>
        <a href="#core-features">
          Features
        </a>
      </li>
      <li>
        <a href="#system-overview">
          Architecture
        </a>
      </li>
          <li><a style={{ opacity: 0.5, cursor: "not-allowed", pointerEvents: "none" }}>Demo</a></li>
        </ul>
        <div className="nav-btns">
          <ThemeToggle />
          <Link to="/login" style={{ textDecoration: 'none' }}>
            <button className="btn-outline">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4" />
                <polyline points="10 17 15 12 10 7" />
                <line x1="15" y1="12" x2="3" y2="12" />
              </svg>
              Login
            </button>
          </Link>
          <Link to="/signup" style={{ textDecoration: 'none' }}>
            <button className="btn-primary">
              <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
                <circle cx="9" cy="7" r="4" />
                <line x1="19" y1="8" x2="19" y2="14" />
                <line x1="22" y1="11" x2="16" y2="11" />
              </svg>
              Sign Up
            </button>
          </Link>
        </div>
      </nav>
    );
  }

  // Auth pages navbar (login/signup)
  if (variant === 'auth') {
    return (
      <nav>
        <Logo />
        <div className="nav-right">
          <ThemeToggle />
          <Link to="/login" className="btn-nav btn-outline">
            <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
              <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4M10 17l5-5-5-5M15 12H3" />
            </svg>
            Login
          </Link>
          <Link to="/signup" className="btn-nav btn-filled">
            <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
              <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
              <circle cx="9" cy="7" r="4" />
              <line x1="19" y1="8" x2="19" y2="14" />
              <line x1="22" y1="11" x2="16" y2="11" />
            </svg>
            Sign Up
          </Link>
        </div>
      </nav>
    );
  }

  // Dashboard navbar
  if (variant === 'dashboard') {
    const dashboardLinks = user?.role === 'admin'
      ? [
          { to: '/dashboard', label: 'Dashboard' },
          { to: '/employees', label: 'Employees' },
          { to: '/attendance-admin', label: 'Attendance' },
          { to: '/security-alerts', label: 'Alerts' },
          { to: '/cameras', label: 'Cameras' },
        ]
      : [
          { to: '/my-dashboard', label: 'Dashboard' },
          { to: '/attendance', label: 'Attendance' },
        ];

    return (
      <nav>
        <Logo />
        <div className="nav-links">
          {dashboardLinks.map(link => (
            <Link
              key={link.to}
              to={link.to}
              className={location.pathname === link.to ? 'active' : ''}
            >
              {link.label}
            </Link>
          ))}
        </div>
        <div className="nav-right">
          <ThemeToggle />
          {user && (
            <span className="welcome-text">
              Welcome, <strong>{user.name}</strong>
            </span>
          )}
          <button className="btn-logout" onClick={logout}>
            <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24" width="14" height="14">
              <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9" />
            </svg>
            Logout
          </button>
        </div>
      </nav>
    );
  }

  return null;
}

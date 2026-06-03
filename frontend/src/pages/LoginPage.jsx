import { useState, useEffect } from 'react';
import { useNavigate, Link } from 'react-router-dom';
import Navbar from '../components/Navbar';
import { useAuth } from '../context/AuthContext';

export default function LoginPage() {

  useEffect(() => {
    document.title = "Login — SafetyWatch";
  }, []);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [currentRole, setCurrentRole] = useState('employee');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { login } = useAuth();

  const clearError = () => setError('');

  const handleLogin = async () => {
    clearError();
    if (!email || !password) {
      setError('Please fill in both email and password.');
      return;
    }
    setLoading(true);
    const result = await login(email, password);
    setLoading(false);
    if (result.success) {
      navigate(result.role === 'admin' ? '/dashboard' : '/my-dashboard');
    } else {
      setError(result.message || 'Invalid email or password. Please try again.');
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter') handleLogin();
  };

  return (
    <>
      <Navbar variant="auth" />
      <div className="page-center" onKeyDown={handleKeyDown}>
        <div className="page-heading">
          <h1>Welcome Back</h1>
          <p>Sign in to access SafetyWatch</p>
        </div>

        <div className={`form-card${error ? ' shake-anim' : ''}`} id="formCard">
          <div className="role-toggle">
            <button
              className={`role-btn${currentRole === 'employee' ? ' active' : ''}`}
              onClick={() => { setCurrentRole('employee'); clearError(); }}
            >
              <svg fill="none" stroke="currentColor" strokeWidth="1.7" viewBox="0 0 24 24">
                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2" />
                <circle cx="12" cy="7" r="4" />
              </svg>
              <span>Employee</span>
            </button>
            <button
              className={`role-btn${currentRole === 'admin' ? ' active' : ''}`}
              onClick={() => { setCurrentRole('admin'); clearError(); }}
            >
              <svg fill="none" stroke="currentColor" strokeWidth="1.7" viewBox="0 0 24 24">
                <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z" />
              </svg>
              <span>Admin</span>
            </button>
          </div>

          {error && (
            <div className="error-msg visible">
              <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
                <circle cx="12" cy="12" r="10" />
                <line x1="12" y1="8" x2="12" y2="12" />
                <line x1="12" y1="16" x2="12.01" y2="16" />
              </svg>
              <span>{error}</span>
            </div>
          )}

          <div className="field">
            <label>Email</label>
            <input
              type="email"
              placeholder="Enter your email"
              value={email}
              onChange={(e) => setEmail(e.target.value)}
              className={error ? 'input-error' : ''}
            />
          </div>

          <div className="field">
            <label>Password</label>
            <input
              type="password"
              placeholder="Enter your password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className={error ? 'input-error' : ''}
            />
          </div>

          <button className="btn-submit" onClick={handleLogin} disabled={loading}>
            {loading ? 'Signing in…' : 'Sign In'}
          </button>

          <div className="signin-row">
            Don't have an account? <Link to="/signup">Sign Up</Link>
          </div>

        </div>
      </div>
    </>
  );
}

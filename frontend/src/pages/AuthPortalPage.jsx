import { useState, useEffect } from 'react';
import { useLocation, useNavigate } from 'react-router-dom';
import Navbar from '../components/Navbar';
import { useAuth } from '../context/AuthContext';

/* ─── LOGIN CONTENT ────────────────────────────────────────────── */
function LoginContent({ switchToSignup }) {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [rememberMe, setRememberMe] = useState(false);
  const [currentRole, setCurrentRole] = useState('employee');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();
  const { login } = useAuth();
  const location = useLocation();
  const registered = location.state?.registered;
  const registeredName = location.state?.name;

  const clearError = () => setError('');

  const handleLogin = async () => {
    clearError();
    if (!email || !password) {
      setError('Please fill in both email and password.');
      return;
    }
    setLoading(true);
    const result = await login(email, password, currentRole, rememberMe);
    setLoading(false);
    if (result.success) {
      setTimeout(() => {
        if (!rememberMe) {
          navigate('/');
        } else {
          navigate(result.role === 'admin' ? '/dashboard' : '/my-dashboard');
        }
      }, 700);
    } else {
      setError(result.message || 'Invalid email or password. Please try again.');
    }
  };

  const handleKeyDown = (e) => {
    if (e.key === 'Enter') handleLogin();
  };

  return (
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

        {registered && (
          <div className="error-msg visible" style={{background:'rgba(34,197,94,0.1)', borderColor:'rgba(34,197,94,0.3)', color:'#4ade80', marginBottom:'0.5rem'}}>
            <span>✅ Account created{registeredName ? ` for ${registeredName}` : ''}! Please log in to continue.</span>
          </div>
        )}

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
          <div style={{position:'relative'}}>
            <input
              type={showPassword ? 'text' : 'password'}
              placeholder="Enter your password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              className={error ? 'input-error' : ''}
              style={{paddingRight:'2.5rem'}}
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              style={{position:'absolute', right:'0.75rem', top:'50%', transform:'translateY(-50%)',
                background:'none', border:'none', cursor:'pointer', color:'var(--text-secondary)', padding:0}}
            >
              {showPassword ? (
                <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
                  <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/>
                  <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>
                  <line x1="1" y1="1" x2="23" y2="23"/>
                </svg>
              ) : (
                <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
                  <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                  <circle cx="12" cy="12" r="3"/>
                </svg>
              )}
            </button>
          </div>
        </div>

        <div className="remember-me-container" style={{display:'flex', alignItems:'center', gap:'8px', marginBottom:'1.2rem', marginTop:'0.5rem', fontSize:'0.9rem', color:'var(--text-secondary)'}}>
          <input 
            type="checkbox" 
            id="rememberMe" 
            checked={rememberMe}
            onChange={(e) => setRememberMe(e.target.checked)}
            className="custom-checkbox"
          />
          <label htmlFor="rememberMe" style={{cursor:'pointer', userSelect:'none'}}>Remember me</label>
        </div>

        <button className="btn-submit" onClick={handleLogin} disabled={loading}>
          {loading ? 'Signing in…' : 'Sign In'}
        </button>

        <div className="signin-row">
          Don't have an account? <a href="#" onClick={(e) => { e.preventDefault(); switchToSignup(); }}>Sign Up</a>
        </div>
      </div>
    </div>
  );
}

/* ─── SIGNUP CONTENT ────────────────────────────────────────────── */

// Password strength checker
function getPasswordStrength(pwd) {
  const criteria = {
    length:    pwd.length >= 8,
    uppercase: /[A-Z]/.test(pwd),
    lowercase: /[a-z]/.test(pwd),
    number:    /[0-9]/.test(pwd),
    special:   /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(pwd),
  };
  const score = Object.values(criteria).filter(Boolean).length;
  return { criteria, score };
}

function SignupContent({ switchToLogin }) {
  const [role, setRole] = useState('employee');
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);
  const navigate = useNavigate();
  const { register } = useAuth();

  const { criteria, score } = getPasswordStrength(password);
  const allCriteriaMet = score === 5;
  const passwordsMatch = password && confirmPassword && password === confirmPassword;
  const canSubmit = name && email && allCriteriaMet && passwordsMatch && !loading && !success;

  const strengthLabel = ['', 'Very Weak', 'Weak', 'Fair', 'Strong', 'Very Strong'][score];
  const strengthColor = ['', '#ef4444', '#f97316', '#eab308', '#22c55e', '#16a34a'][score];

  const handleRegister = async () => {
    setError('');
    if (!name || !email || !password || !confirmPassword) {
      setError('Please fill in all fields.');
      return;
    }
    if (!allCriteriaMet) {
      setError('Password does not meet the required criteria.');
      return;
    }
    if (!passwordsMatch) {
      setError('Passwords do not match.');
      return;
    }

    setLoading(true);
    const result = await register(name, email.trim().toLowerCase(), password, role);
    setLoading(false);

    if (result.success) {
      setSuccess(true);
      if (role === 'admin') {
        setTimeout(() => switchToLogin(), 3000);
      }
    } else {
      setError(result.message || 'Registration failed. Please try again.');
    }
  };

  return (
    <div className="page-center">
      <div className="page-heading">
        <h1>Create Account</h1>
        <p>Join SafetyWatch</p>
      </div>
      <div className={`form-card${error ? ' shake-anim' : ''}`}>

        {/* Role Toggle */}
        <div className="role-toggle">
          <button
            className={`role-btn ${role === 'employee' ? 'active' : ''}`}
            onClick={() => setRole('employee')}
          >
            <svg fill="none" stroke="currentColor" strokeWidth="1.7" viewBox="0 0 24 24">
              <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
              <circle cx="12" cy="7" r="4"/>
            </svg>
            <span>Sign up as Employee</span>
          </button>
          <button
            className={`role-btn ${role === 'admin' ? 'active' : ''}`}
            onClick={() => setRole('admin')}
          >
            <svg fill="none" stroke="currentColor" strokeWidth="1.7" viewBox="0 0 24 24">
              <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
            </svg>
            <span>Sign up as Admin</span>
          </button>
        </div>

        {error && (
          <div className="error-msg visible">
            <svg fill="none" stroke="currentColor" strokeWidth="2" viewBox="0 0 24 24">
              <circle cx="12" cy="12" r="10"/>
              <line x1="12" y1="8" x2="12" y2="12"/>
              <line x1="12" y1="16" x2="12.01" y2="16"/>
            </svg>
            <span>{error}</span>
          </div>
        )}

        {success && (
          <div className="error-msg visible" style={{background:'rgba(34,197,94,0.1)', borderColor:'rgba(34,197,94,0.3)', color:'#4ade80', marginBottom:'1rem'}}>
            {role === 'admin' ? (
              <>
                <span>Account created successfully! You can now log in.</span>
                <br/>
                <button
                  style={{marginTop:'0.75rem', background:'rgba(34,197,94,0.2)', border:'1px solid rgba(34,197,94,0.4)', color:'#4ade80', padding:'0.4rem 1rem', borderRadius:'6px', cursor:'pointer', fontSize:'0.85rem'}}
                  onClick={() => switchToLogin()}
                >
                  Go to Login
                </button>
              </>
            ) : (
              <>
                <span>Account created! Your account is <strong>pending admin approval</strong>. You will be able to log in once an admin activates your account.</span>
                <br/>
                <button
                  style={{marginTop:'0.75rem', background:'rgba(34,197,94,0.2)', border:'1px solid rgba(34,197,94,0.4)', color:'#4ade80', padding:'0.4rem 1rem', borderRadius:'6px', cursor:'pointer', fontSize:'0.85rem'}}
                  onClick={() => switchToLogin()}
                >
                  Go to Login
                </button>
              </>
            )}
          </div>
        )}

        <div className="field">
          <label>Full Name</label>
          <input type="text" placeholder="Enter your full name"
            value={name} onChange={(e) => setName(e.target.value)} />
        </div>

        <div className="field">
          <label>Email</label>
          <input
            type="email"
            placeholder="Enter your email address"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
          />
        </div>

        {/* Password field with show/hide toggle */}
        <div className="field">
          <label>Password</label>
          <div style={{position:'relative'}}>
            <input
              type={showPassword ? 'text' : 'password'}
              placeholder="Create a strong password"
              value={password}
              onChange={(e) => setPassword(e.target.value)}
              style={{paddingRight:'2.5rem'}}
            />
            <button
              type="button"
              onClick={() => setShowPassword(!showPassword)}
              style={{position:'absolute', right:'0.75rem', top:'50%', transform:'translateY(-50%)',
                background:'none', border:'none', cursor:'pointer', color:'var(--text-secondary)', padding:0}}
            >
              {showPassword ? (
                <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
                  <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20c-7 0-11-8-11-8a18.45 18.45 0 0 1 5.06-5.94"/>
                  <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4c7 0 11 8 11 8a18.5 18.5 0 0 1-2.16 3.19"/>
                  <line x1="1" y1="1" x2="23" y2="23"/>
                </svg>
              ) : (
                <svg width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
                  <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                  <circle cx="12" cy="12" r="3"/>
                </svg>
              )}
            </button>
          </div>

          {/* Strength Bar */}
          {password && (
            <div style={{marginTop:'0.5rem'}}>
              <div style={{display:'flex', gap:'4px', marginBottom:'4px'}}>
                {[1,2,3,4,5].map(i => (
                  <div key={i} style={{
                    flex:1, height:'4px', borderRadius:'2px',
                    background: i <= score ? strengthColor : 'rgba(255,255,255,0.1)',
                    transition: 'background 0.3s'
                  }}/>
                ))}
              </div>
              <span style={{fontSize:'0.72rem', color: strengthColor, fontWeight:'600'}}>{strengthLabel}</span>
            </div>
          )}

          {/* Criteria Checklist */}
          {password && (
            <div style={{marginTop:'0.6rem', display:'flex', flexDirection:'column', gap:'3px'}}>
              {[
                { key:'length',    label:'At least 8 characters' },
                { key:'uppercase', label:'One uppercase letter (A-Z)' },
                { key:'lowercase', label:'One lowercase letter (a-z)' },
                { key:'number',    label:'One number (0-9)' },
                { key:'special',   label:'One special character (!@#$%)' },
              ].map(({ key, label }) => (
                <div key={key} style={{display:'flex', alignItems:'center', gap:'6px', fontSize:'0.72rem',
                  color: criteria[key] ? '#4ade80' : 'var(--text-secondary)'}}>
                  <span style={{display:'flex', alignItems:'center'}}>
                    {criteria[key] ? (
                      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="#4ade80" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                        <polyline points="20 6 9 17 4 12"></polyline>
                      </svg>
                    ) : (
                      <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round">
                        <line x1="18" y1="6" x2="6" y2="18"></line>
                        <line x1="6" y1="6" x2="18" y2="18"></line>
                      </svg>
                    )}
                  </span>
                  <span>{label}</span>
                </div>
              ))}
            </div>
          )}
        </div>

        {/* Confirm Password */}
        <div className="field">
          <label>Confirm Password</label>
          <div style={{position:'relative'}}>
            <input
              type="password"
              placeholder="Confirm your password"
              value={confirmPassword}
              onChange={(e) => setConfirmPassword(e.target.value)}
              style={{paddingRight:'2.5rem',
                borderColor: confirmPassword ? (passwordsMatch ? 'rgba(34,197,94,0.5)' : 'rgba(239,68,68,0.5)') : ''}}
            />
            {confirmPassword && (
              <span style={{position:'absolute', right:'0.75rem', top:'50%', transform:'translateY(-50%)', display:'flex', alignItems:'center'}}>
                {passwordsMatch ? (
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#22c55e" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                    <polyline points="20 6 9 17 4 12"></polyline>
                  </svg>
                ) : (
                  <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#ef4444" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
                    <line x1="18" y1="6" x2="6" y2="18"></line>
                    <line x1="6" y1="6" x2="18" y2="18"></line>
                  </svg>
                )}
              </span>
            )}
          </div>
        </div>

        <button
          className="btn-submit"
          onClick={handleRegister}
          disabled={!canSubmit}
          style={{opacity: canSubmit ? 1 : 0.5, cursor: canSubmit ? 'pointer' : 'not-allowed'}}
        >
          {loading ? 'Creating Account…' : 'Create Account'}
        </button>

        <div className="signin-row">
          Already have an account? <a href="#" onClick={(e) => { e.preventDefault(); switchToLogin(); }}>Sign In</a>
        </div>
      </div>
    </div>
  );
}


/* ─── PORTAL (COMBINED PAGE) ──────────────────────────────────── */
export default function AuthPortalPage() {
  const location = useLocation();
  const navigate = useNavigate();

  // Determine active tab from URL (/login or /signup)
  const activeTab = location.pathname === '/signup' ? 'signup' : 'login';
  const [displayedTab, setDisplayedTab] = useState(activeTab);
  const [isTransitioning, setIsTransitioning] = useState(false);

  useEffect(() => {

  }, [activeTab]);

  useEffect(() => {
    if (activeTab !== displayedTab) {
      // Start fade-out
      setIsTransitioning(true);
      // After fade-out, swap content and fade-in
      const timeout = setTimeout(() => {
        setDisplayedTab(activeTab);
        setIsTransitioning(false);
      }, 250);
      return () => clearTimeout(timeout);
    }
  }, [activeTab, displayedTab]);

  const switchToLogin = () => navigate('/login');
  const switchToSignup = () => navigate('/signup');

  return (
    <>
      <Navbar variant="auth" />
      <div className={`tab-content ${isTransitioning ? 'tab-fade-out' : 'tab-fade-in'}`}>
        {displayedTab === 'login' ? (
          <LoginContent switchToSignup={switchToSignup} />
        ) : (
          <SignupContent switchToLogin={switchToLogin} />
        )}
      </div>
    </>
  );
}

import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import Navbar from '../components/Navbar';

export default function SignupPage() {

  useEffect(() => {

  }, []);
  const [role, setRole] = useState('employee');

  return (
    <>
      <Navbar variant="auth" />
      <div className="page-center">
        <div className="page-heading">
          <h1>Create Account</h1>
          <p>Join SafetyWatch</p>
        </div>
        <div className="form-card">
          
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

          {/* Fields */}
          <div className="field">
            <label>Full Name</label>
            <input type="text" placeholder="Enter your full name" />
          </div>
          <div className="field">
            <label>Email</label>
            <input type="email" placeholder="Enter your email" />
          </div>
          <div className="field">
            <label>Password</label>
            <input type="password" placeholder="Create a password" />
          </div>
          <div className="field">
            <label>Confirm Password</label>
            <input type="password" placeholder="Confirm your password" />
          </div>
          
          <button className="btn-submit">Create Account</button>

          {/* Signin Row */}
          <div className="signin-row">
            Already have an account? <Link to="/login">Sign In</Link>
          </div>
        </div>
      </div>
    </>
  );
}

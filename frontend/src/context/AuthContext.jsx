import { createContext, useContext, useState } from 'react';

const BASE_URL = import.meta.env.VITE_API_URL || '/api';

const AuthContext = createContext();

// Demo credentials — for the "Fill" button on the login page only
const DEMO_CREDENTIALS = {
  employee: { email: 'user@safetywatch.com', password: 'user123' },
  admin:    { email: 'admin@safetywatch.com', password: 'admin123' },
};

export function AuthProvider({ children }) {
  const [user, setUser] = useState(() => {
    try {
      const saved = sessionStorage.getItem('sw_user') || localStorage.getItem('sw_user');
      return saved ? JSON.parse(saved) : null;
    } catch {
      return null;
    }
  });

  // POST /api/auth/login — real Laravel API call
  const login = async (email, password, requestedRole, rememberMe = true) => {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000); // 10s timeout

    try {
      const res = await fetch(`${BASE_URL}/auth/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ email: email.trim().toLowerCase(), password }),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);
      const json = await res.json();

      if (!res.ok) {
        return { success: false, message: json.message || 'Invalid email or password.' };
      }

      const { user: userData, token } = json.data;

      // Ensure the user is logging into the correct portal
      if (requestedRole && userData.role !== requestedRole) {
        return { 
          success: false, 
          message: `This account does not have ${requestedRole === 'admin' ? 'an admin' : 'an employee'} profile.` 
        };
      }

      const userToStore = {
        id:    userData.id,
        name:  userData.name,
        email: userData.email,
        role:  userData.role,
      };

      // Store token based on rememberMe preference
      if (rememberMe) {
        localStorage.setItem('sw_token', token);
        localStorage.setItem('sw_user', JSON.stringify(userToStore));
      } else {
        sessionStorage.setItem('sw_token', token);
        sessionStorage.setItem('sw_user', JSON.stringify(userToStore));
      }

      setUser(userToStore);

      return { success: true, role: userData.role };

    } catch (err) {
      clearTimeout(timeoutId);
      if (err.name === 'AbortError') {
        return { success: false, message: 'Connection timed out. Is the backend (Herd) running?' };
      }
      console.error('Login error:', err);
      return { success: false, message: 'Could not connect to server. Is Laravel running?' };
    }
  };

  // POST /api/auth/register — real Laravel API call
  const register = async (name, email, password, role = 'employee') => {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000);

    try {
      const res = await fetch(`${BASE_URL}/auth/register`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
        body: JSON.stringify({ name, email, password, password_confirmation: password, role }),
        signal: controller.signal,
      });

      clearTimeout(timeoutId);
      const json = await res.json();

      if (!res.ok) {
        const firstError = json.errors ? Object.values(json.errors)[0]?.[0] : null;
        return { success: false, message: firstError || json.message || 'Registration failed.' };
      }

      const { user: userData } = json.data;
      // No auto-login — user must log in manually after registration
      return { success: true, name: userData.name };

    } catch (err) {
      clearTimeout(timeoutId);
      if (err.name === 'AbortError') {
        return { success: false, message: 'Connection timed out. Is the backend (Herd) running?' };
      }
      return { success: false, message: 'Could not connect to server.' };
    }
  };

  // POST /api/auth/logout — revoke server-side Sanctum token
  const logout = async () => {
    try {
      const token = sessionStorage.getItem('sw_token') || localStorage.getItem('sw_token');
      if (token) {
        await fetch(`${BASE_URL}/auth/logout`, {
          method: 'POST',
          headers: {
            'Authorization': `Bearer ${token}`,
            'Accept': 'application/json'
          }
        });
      }
    } catch (e) {
      console.error('Logout failed:', e);
    } finally {
      localStorage.removeItem('sw_token');
      localStorage.removeItem('sw_user');
      sessionStorage.removeItem('sw_token');
      sessionStorage.removeItem('sw_user');
      setUser(null);
    }
  };

  return (
    <AuthContext.Provider value={{ user, login, logout, register, DEMO_CREDENTIALS }}>

      {children}
    </AuthContext.Provider>
  );
}


export function useAuth() {
  return useContext(AuthContext);
}


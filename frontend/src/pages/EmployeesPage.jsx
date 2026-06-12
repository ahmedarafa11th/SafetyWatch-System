import { useState, useEffect } from 'react';
import { createPortal } from 'react-dom';
import { api } from '../api';

export default function EmployeesPage() {

  useEffect(() => {

    fetchEmployees();
  }, []);

  const [employees, setEmployees] = useState([]);
  const [isLoading, setIsLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [modalOpen, setModalOpen] = useState(false);
  const [editEmployee, setEditEmployee] = useState(null); // null = add, object = edit
  const [isSaving, setIsSaving] = useState(false);
  const [showTimeInputs, setShowTimeInputs] = useState(false);

  const [formData, setFormData] = useState({
    name: '', email: '', department: '',
    position: '', status: 'active', join_date: '',
    phone: '', shift_start: '08:00', shift_end: '17:00',
    photo_front: null, photo_left: null, photo_right: null,
  });

  const fetchEmployees = async (search = '') => {
    setIsLoading(true);
    try {
      const endpoint = search ? `/admin/employees?search=${encodeURIComponent(search)}` : '/admin/employees';
      const res = await api.get(endpoint);
      // paginated() returns { data: [...], meta: {...} }
      setEmployees(Array.isArray(res.data) ? res.data : (res.data || []));
    } catch (err) {
      console.error('Failed to load employees', err);
    } finally {
      setIsLoading(false);
    }
  };

  // Search with debounce
  useEffect(() => {
    const timer = setTimeout(() => fetchEmployees(searchQuery), 400);
    return () => clearTimeout(timer);
  }, [searchQuery]);

  const getStatusClass = (status) => {
    if (status === 'active') return 'badge-green';
    if (status === 'on_leave') return 'badge-medium';
    return 'badge-red';
  };

  const formatDate = (ds) => {
    if (!ds) return '—';
    return new Date(ds).toLocaleDateString();
  };

  const openModal = (employee = null) => {
    setEditEmployee(employee);
    if (employee) {
      setFormData({
        name: employee.user?.name || '',
        email: employee.user?.email || '',
        password: '',
        department: employee.department || '',
        position: employee.position || '',
        status: employee.status || 'active',
        join_date: employee.join_date || '',
        phone: employee.phone || '',
        shift_start: employee.shift_start?.slice(0, 5) || '08:00',
        shift_end: employee.shift_end?.slice(0, 5) || '17:00',
        photo_front: null, photo_left: null, photo_right: null,
      });
    } else {
      setFormData({
        name: '', email: '', department: '',
        position: '', status: 'active', join_date: '',
        phone: '', shift_start: '08:00', shift_end: '17:00',
        photo_front: null, photo_left: null, photo_right: null,
      });
    }
    setModalOpen(true);
    document.body.style.overflow = 'hidden';
  };

  const closeModal = () => {
    setModalOpen(false);
    setEditEmployee(null);
    document.body.style.overflow = '';
  };

  const handleSave = async () => {
    if (!formData.department || !formData.position || !formData.status || !formData.join_date) {
      alert("Please fill all required fields.");
      return;
    }
    if (!editEmployee && (!formData.photo_front || !formData.photo_left || !formData.photo_right)) {
      alert("All 3 Face Recognition Photos (Front, Right, Left) are required to add a new employee.");
      return;
    }
    if (!editEmployee && !formData.email) {
      alert("Email is required. It must belong to an existing account.");
      return;
    }

    setIsSaving(true);
    try {
      let payload = formData;
      
      // If we have files, we must send FormData instead of JSON
      if (formData.photo_front || formData.photo_left || formData.photo_right) {
        payload = new FormData();
        Object.keys(formData).forEach(key => {
          if (formData[key] !== null && formData[key] !== undefined && formData[key] !== '') {
            payload.append(key, formData[key]);
          }
        });
        if (editEmployee) {
          payload.append('_method', 'PUT'); // Laravel requirement for multipart PUT requests
        }
      }

      if (editEmployee) {
        // If it's multipart, we send as POST with _method=PUT to Laravel
        if (payload instanceof FormData) {
          await api.post(`/admin/employees/${editEmployee.id}`, payload);
        } else {
          await api.put(`/admin/employees/${editEmployee.id}`, payload);
        }
      } else {
        await api.post('/admin/employees', payload);
      }
      fetchEmployees(searchQuery);
      closeModal();
    } catch (err) {
      alert(err.message || 'Failed to save employee');
    } finally {
      setIsSaving(false);
    }
  };

  const handleDelete = async (id) => {
    if (window.confirm("Are you sure you want to delete this employee?")) {
      try {
        await api.delete(`/admin/employees/${id}`);
        fetchEmployees(searchQuery);
      } catch (err) {
        alert(err.message || 'Failed to delete employee');
      }
    }
  };

  return (
    <>
      <div className="page-header">
        <div className="page-title">
          <h1>Employees</h1>
          <p>Manage staff, roles, and access levels</p>
        </div>
        <div className="page-actions">
          <button className="btn-add" onClick={() => openModal()}>
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
              <line x1="12" y1="5" x2="12" y2="19"/><line x1="5" y1="12" x2="19" y2="12"/>
            </svg>
            Add Employee
          </button>
        </div>
      </div>

      {/* SEARCH */}
      <div className="search-wrap">
        <div className="search-input">
          <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>
          </svg>
          <input
            type="text"
            placeholder="Search employees..."
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
          />
        </div>
      </div>

      {/* TABLE */}
      {isLoading ? (
        <div style={{ padding: '2rem', textAlign: 'center', color: 'var(--text-secondary)' }}>Loading employees...</div>
      ) : (
        <div className="table-card">
          <table>
            <thead>
              <tr>
                <th>Employee Name</th>
                <th>Department</th>
                <th>Position</th>
                <th>Status</th>
                <th>Join Date</th>
                <th style={{ width: "100px" }}>Actions</th>
              </tr>
            </thead>
            <tbody>
              {employees.length === 0 ? (
                <tr>
                  <td colSpan={6} style={{ textAlign: 'center', color: 'var(--text-secondary)', padding: '1.5rem' }}>
                    No employees found.
                  </td>
                </tr>
              ) : employees.map((emp) => (
                <tr key={emp.id}>
                  <td><div className="type-cell"><strong>{emp.user?.name || '—'}</strong></div></td>
                  <td>{emp.department}</td>
                  <td>{emp.position}</td>
                  <td>
                    <span className={`badge ${getStatusClass(emp.status)}`}>
                      {emp.status.replace('_', ' ').charAt(0).toUpperCase() + emp.status.slice(1)}
                    </span>
                  </td>
                  <td className="mono">{formatDate(emp.join_date)}</td>
                  <td className="actions-cell">
                    <button className="btn-edit" onClick={() => openModal(emp)}>
                      <svg width="14" height="14" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
                        <polygon points="16 3 21 8 8 21 3 21 3 16 16 3"></polygon>
                      </svg>
                    </button>
                    <button className="btn-delete" onClick={() => handleDelete(emp.id)}>
                      <svg width="14" height="14" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
                        <polyline points="3 6 5 6 21 6"></polyline>
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                      </svg>
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {/* ADD / EDIT MODAL */}
      {modalOpen && createPortal(
        <div className="modal-overlay open" onClick={(e) => { if (e.target === e.currentTarget) closeModal(); }}>
          <div className="modal" style={{ maxWidth: '850px', width: '90%' }}>
            <h2>{editEmployee ? 'Edit Employee' : 'Add New Employee'}</h2>

            <div style={{ display: 'flex', flexWrap: 'wrap', gap: '2rem' }}>
              
              {/* Left Side: Employee Details */}
              <div style={{ flex: '1 1 300px' }}>
                {!editEmployee && (
                  <div className="form-group">
                    <label>Email * <span style={{fontSize:'0.75rem', color:'var(--text-secondary)', fontWeight:'400'}}>(must be a registered account)</span></label>
                    <input type="email" placeholder="e.g. ahmed@safetywatch.com"
                      value={formData.email} onChange={(e) => setFormData({...formData, email: e.target.value})} />
                    <p style={{fontSize:'0.75rem', color:'var(--text-secondary)', marginTop:'0.3rem'}}>
                      The user must have an existing account. New accounts are created via Sign Up.
                    </p>
                  </div>
                )}

                <div className="form-group">
                  <label>Department *</label>
                  <input type="text" placeholder="e.g. Software Engineering"
                    value={formData.department} onChange={(e) => setFormData({...formData, department: e.target.value})} />
                </div>

                <div className="form-group">
                  <label>Position *</label>
                  <input type="text" placeholder="e.g. Backend Developer"
                    value={formData.position} onChange={(e) => setFormData({...formData, position: e.target.value})} />
                </div>

                <div className="form-group">
                  <label>Join Date *</label>
                  <input type="date" value={formData.join_date}
                    onChange={(e) => setFormData({...formData, join_date: e.target.value})} />
                </div>

                <div className="form-group">
                  <label>Phone</label>
                  <input type="text" placeholder="e.g. +20 1XX XXX XXXX"
                    value={formData.phone} onChange={(e) => setFormData({...formData, phone: e.target.value})} />
                </div>

                <div className="form-group">
                  <label>Status *</label>
                  <select value={formData.status} onChange={(e) => setFormData({...formData, status: e.target.value})}>
                    <option value="active">Active</option>
                    <option value="inactive">Inactive</option>
                    <option value="on_leave">On Leave</option>
                  </select>
                </div>
              </div>

              {/* Right Side: Photos & Time */}
              <div style={{ flex: '1 1 300px', display: 'flex', flexDirection: 'column', gap: '1.5rem' }}>
                <div style={{ padding: '1.5rem', background: 'var(--surface)', borderRadius: '12px', border: '1px solid var(--border)' }}>
                  <h4 style={{ marginBottom: '0.5rem', color: 'var(--text-primary)' }}>Face Recognition Photos {!editEmployee && '*'}</h4>
                  <p style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginBottom: '1.5rem', lineHeight: '1.4' }}>
                    Upload 3 photos of the employee's face for AI attendance tracking. Mandatory for new employees.
                  </p>
                  
                  {['front', 'right', 'left'].map((side) => (
                    <div key={side} className="form-group" style={{ marginBottom: '1.25rem' }}>
                      <label style={{ textTransform: 'capitalize', fontWeight: '500', marginBottom: '0.5rem', display: 'block' }}>
                        {side} Face Photo {!editEmployee && '*'}
                      </label>
                      <label className="btn-logout" style={{ justifyContent: 'center', width: '100%', padding: '10px 14px', gap: '10px' }}>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ width: '16px', height: '16px', flexShrink: 0, transform: 'translateY(1.5px)', marginRight: '8px' }}>
                          <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                          <polyline points="17 8 12 3 7 8"></polyline>
                          <line x1="12" y1="3" x2="12" y2="15"></line>
                        </svg>
                        <span style={{ textTransform: 'capitalize', lineHeight: '1' }}>
                          {formData[`photo_${side}`] ? formData[`photo_${side}`].name : 'Choose Image'}
                        </span>
                        <input type="file" accept="image/jpeg, image/png, image/jpg" 
                          style={{ display: 'none' }}
                          onChange={(e) => setFormData({...formData, [`photo_${side}`]: e.target.files[0]})} />
                      </label>
                    </div>
                  ))}
                </div>

                <div style={{ padding: '1.5rem', background: 'var(--surface)', borderRadius: '12px', border: '1px solid var(--border)' }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: showTimeInputs ? '1.5rem' : '0' }}>
                    <div>
                      <h4 style={{ margin: 0, color: 'var(--text-primary)' }}>Check-in Time</h4>
                      {(!showTimeInputs && formData.shift_start) && (
                        <div style={{ fontSize: '0.85rem', color: 'var(--text-secondary)', marginTop: '0.2rem' }}>
                          Set to: <strong>{formData.shift_start}</strong>
                        </div>
                      )}
                    </div>
                    <button type="button" className="btn-logout" onClick={() => setShowTimeInputs(!showTimeInputs)}>
                      {showTimeInputs ? 'Hide' : 'Configure'}
                    </button>
                  </div>
                  
                  {showTimeInputs && (
                    <div style={{ display: 'flex', gap: '1rem' }}>
                      <div className="form-group" style={{ flex: 1, margin: 0 }}>
                        <label style={{ fontSize: '0.8rem', marginBottom: '0.4rem' }}>Hours (24h)</label>
                        <select 
                          style={{ width: '100%' }}
                          value={formData.shift_start.split(':')[0]} 
                          onChange={(e) => setFormData({...formData, shift_start: `${e.target.value}:${formData.shift_start.split(':')[1]}`})}
                        >
                          {Array.from({ length: 24 }, (_, i) => i.toString().padStart(2, '0')).map(h => (
                            <option key={h} value={h}>{h}</option>
                          ))}
                        </select>
                      </div>
                      <div className="form-group" style={{ flex: 1, margin: 0 }}>
                        <label style={{ fontSize: '0.8rem', marginBottom: '0.4rem' }}>Minutes</label>
                        <select 
                          style={{ width: '100%' }}
                          value={formData.shift_start.split(':')[1]} 
                          onChange={(e) => setFormData({...formData, shift_start: `${formData.shift_start.split(':')[0]}:${e.target.value}`})}
                        >
                          {Array.from({ length: 60 }, (_, i) => i.toString().padStart(2, '0')).map(m => (
                            <option key={m} value={m}>{m}</option>
                          ))}
                        </select>
                      </div>
                    </div>
                  )}
                </div>
              </div>

            </div>

            <div className="modal-actions" style={{ marginTop: '2rem' }}>
              <button className="btn-cancel" onClick={closeModal} disabled={isSaving}>Cancel</button>
              <button className="btn-save" onClick={handleSave} disabled={isSaving}>
                {isSaving ? 'Saving...' : (editEmployee ? 'Save Changes' : 'Add Employee')}
              </button>
            </div>
          </div>
        </div>,
        document.body
      )}
    </>
  );
}

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

  // Form matches EmployeeRequest validation in Laravel
  const [formData, setFormData] = useState({
    name: '', email: '', department: '',
    position: '', status: 'active', join_date: '',
    phone: '', shift_start: '08:00', shift_end: '17:00',
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
      });
    } else {
      setFormData({
        name: '', email: '', department: '',
        position: '', status: 'active', join_date: '',
        phone: '', shift_start: '08:00', shift_end: '17:00',
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
    if (!editEmployee && !formData.email) {
      alert("Email is required. It must belong to an existing account.");
      return;
    }

    setIsSaving(true);
    try {
      if (editEmployee) {
        await api.put(`/admin/employees/${editEmployee.id}`, formData);
      } else {
        await api.post('/admin/employees', formData);
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
          <div className="modal">
            <h2>{editEmployee ? 'Edit Employee' : 'Add New Employee'}</h2>

            {!editEmployee && (
              <div className="form-group">
                <label>Email * <span style={{fontSize:'0.75rem', color:'var(--text-secondary)', fontWeight:'400'}}>(must be a registered account)</span></label>
                <input type="email" placeholder="e.g. ahmed@safetywatch.com"
                  value={formData.email} onChange={(e) => setFormData({...formData, email: e.target.value})} />
                <p style={{fontSize:'0.75rem', color:'var(--text-secondary)', marginTop:'0.3rem'}}>
                  ⚠️ The user must have an existing account. New accounts are created via Sign Up.
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

            <div className="modal-actions">
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

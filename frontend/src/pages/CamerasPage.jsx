import { useState, useEffect, useRef } from 'react';
import { createPortal } from 'react-dom';
import { api } from '../api';

// Detect if URL is a video file (MP4, WebM, etc.)
function isVideoFile(url) {
  if (!url) return false;
  const lower = url.toLowerCase().split('?')[0];
  return lower.endsWith('.mp4') || lower.endsWith('.webm') ||
         lower.endsWith('.ogg') || lower.endsWith('.m3u8') ||
         lower.endsWith('.mov');
}

// Smart stream URL builder
function buildStreamUrl(ip) {
  if (!ip) return null;
  // Already a full URL (including video files)
  if (ip.startsWith('http://') || ip.startsWith('https://')) {
    // If it's a video file, return as-is
    if (isVideoFile(ip)) return ip;
    // If URL has no path or just '/', append /video
    try {
      const u = new URL(ip);
      if (u.pathname === '/' || u.pathname === '') return ip.replace(/\/$/, '') + '/video';
      return ip;
    } catch { return ip; }
  }
  // Bare IP or IP:port
  return `http://${ip}/video`;
}

// ─── Camera Stream Component (supports MJPEG img + MP4 video) ────────────────
function CameraStream({ url, height = '200px' }) {
  const [failed, setFailed]   = useState(false);
  const [loaded, setLoaded]   = useState(false);
  const [retryCount, setRetryCount] = useState(0);
  const isVideo = isVideoFile(url);

  useEffect(() => { setFailed(false); setLoaded(false); setRetryCount(0); }, [url]);

  // Bust cache for MJPEG so browser actually retries the connection
  const activeUrl = isVideo ? url : (url.includes('?') ? `${url}&retry=${retryCount}` : `${url}?retry=${retryCount}`);

  if (!url) return (
    <div style={noStreamStyle(height)}>
      <CamIcon />
      <span>No stream configured</span>
    </div>
  );

  if (failed) return (
    <div style={noStreamStyle(height)}>
      <CamIcon />
      <span style={{ fontSize: '12px' }}>Stream unavailable</span>
      <code style={{ fontSize: '10px', color: '#555', wordBreak: 'break-all', padding: '0 12px', textAlign: 'center' }}>{url}</code>
      <button onClick={() => { setFailed(false); setRetryCount(c => c + 1); }}
        style={{ fontSize: '11px', padding: '4px 12px', background: '#3b82f6', color: '#fff', border: 'none', borderRadius: '6px', cursor: 'pointer', marginTop: '6px' }}>
        ↺ Retry
      </button>
    </div>
  );

  return (
    <div style={{ position: 'relative', width: '100%', height, background: '#000', borderRadius: '10px', overflow: 'hidden' }}>
      {/* Loading spinner */}
      {!loaded && (
        <div style={{ position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', gap: '8px', zIndex: 1 }}>
          <div style={{ width: '26px', height: '26px', border: '2px solid #3b82f6', borderTopColor: 'transparent', borderRadius: '50%', animation: 'spin 0.8s linear infinite' }} />
          <span style={{ fontSize: '12px', color: '#666' }}>Loading stream...</span>
        </div>
      )}

      {isVideo ? (
        /* ── MP4 / Video file ── */
        <video
          src={activeUrl}
          autoPlay
          loop
          muted
          playsInline
          style={{ width: '100%', height: '100%', objectFit: 'cover', display: loaded ? 'block' : 'none' }}
          onCanPlay={() => setLoaded(true)}
          onError={() => setFailed(true)}
        />
      ) : (
        /* ── MJPEG / HTTP image stream ── */
        <img
          src={activeUrl}
          alt="Camera Stream"
          style={{ width: '100%', height: '100%', objectFit: 'cover', display: loaded ? 'block' : 'none' }}
          onLoad={() => setLoaded(true)}
          onError={() => setFailed(true)}
        />
      )}

      {/* LIVE badge */}
      {loaded && (
        <div style={{
          position: 'absolute', top: '8px', right: '8px',
          background: 'rgba(239,68,68,0.9)', color: '#fff',
          fontSize: '10px', fontWeight: 700, padding: '3px 8px',
          borderRadius: '20px', display: 'flex', alignItems: 'center', gap: '5px',
          letterSpacing: '0.5px'
        }}>
          <span style={{ width: '6px', height: '6px', background: '#fff', borderRadius: '50%', display: 'inline-block', animation: 'pulse 1.5s infinite' }} />
          LIVE
        </div>
      )}
    </div>
  );
}

function CamIcon() {
  return (
    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5"
      style={{ width: '36px', opacity: 0.25, marginBottom: '4px' }}>
      <path d="M23 7l-7 5 7 5V7z"/><rect x="1" y="5" width="15" height="14" rx="2" ry="2"/>
    </svg>
  );
}

function noStreamStyle(height) {
  return {
    height, width: '100%', display: 'flex', flexDirection: 'column',
    alignItems: 'center', justifyContent: 'center', gap: '6px',
    background: 'var(--gray-900, #111)', borderRadius: '10px',
    color: 'var(--text-secondary, #888)', fontSize: '13px',
  };
}


// ─── Main Page ────────────────────────────────────────────────────────────────
export default function CamerasPage() {
  useEffect(() => {
    fetchCameras();
    const interval = setInterval(pollCameras, 500);
    return () => clearInterval(interval);
  }, []);

  const [cameras, setCameras]     = useState([]);
  const [stats, setStats]         = useState({ total: 0, online: 0, offline: 0, total_alerts: 0 });
  const [isLoading, setIsLoading] = useState(true);
  const [showAdd, setShowAdd] = useState(false);
  const [showUpload, setShowUpload] = useState(false);
  const [uploadFile, setUploadFile] = useState(null);
  const [selected, setSelected]   = useState(null); // camera id for settings modal
  const [isSaving, setIsSaving]   = useState(false);
  const [addForm, setAddForm] = useState({ name: '', location: '', ip_address: '', status: 'online' });
  const [editForm, setEditForm] = useState({ name: '', location: '', ip_address: '', status: 'online' });
  const [previewId, setPreviewId] = useState(null);

  // ── Fetch ──────────────────────────────────────────────────────────────────
  const fetchCameras = async () => {
    setIsLoading(true);
    try {
      const res = await api.get('/admin/cameras');
      setCameras(res.data.cameras ?? []);
      setStats(res.data.stats ?? { total: 0, online: 0, offline: 0, total_alerts: 0 });
    } catch (err) {
      console.error(err);
    } finally {
      setIsLoading(false);
    }
  };

  const pollCameras = async () => {
    try {
      const res = await api.get('/admin/cameras');
      setCameras(res.data.cameras ?? []);
      setStats(res.data.stats ?? { total: 0, online: 0, offline: 0, total_alerts: 0 });
    } catch (err) {
      // silent fail on polling
    }
  };

  const selectedCam = cameras.find(c => c.id === selected) ?? null;
  const previewCam = cameras.find(c => c.id === previewId) ?? null;

  // ── Add ────────────────────────────────────────────────────────────────────
  const openAdd  = () => { setAddForm({ name: '', location: '', ip_address: '', status: 'online' }); setShowAdd(true); document.body.style.overflow = 'hidden'; };
  const closeAdd = () => { setShowAdd(false); document.body.style.overflow = ''; };

  const handleAdd = async () => {
    if (!addForm.name || !addForm.location) return alert('Name and Location are required.');
    setIsSaving(true);
    try {
      const streamUrl = addForm.ip_address ? buildStreamUrl(addForm.ip_address) : null;
      await api.post('/admin/cameras', {
        name:       addForm.name,
        location:   addForm.location,
        ip_address: addForm.ip_address || null,
        stream_url: streamUrl,
        status:     addForm.status,
      });
      await fetchCameras();
      closeAdd();
    } catch (err) {
      alert(err.message || 'Error adding camera');
    } finally {
      setIsSaving(false);
    }
  };

  // ── Settings ───────────────────────────────────────────────────────────────
  const openSettings = (cam) => {
    setSelected(cam.id);
    setEditForm({ name: cam.name, location: cam.location, ip_address: cam.ip_address || '', status: cam.status });
    document.body.style.overflow = 'hidden';
  };
  const closeSettings = () => { setSelected(null); document.body.style.overflow = ''; };

  const handleSave = async () => {
    setIsSaving(true);
    try {
      const streamUrl = editForm.ip_address ? buildStreamUrl(editForm.ip_address) : null;
      await api.put(`/admin/cameras/${selected}`, {
        name:       editForm.name,
        location:   editForm.location,
        ip_address: editForm.ip_address || null,
        stream_url: streamUrl,
        status:     editForm.status,
      });
      await fetchCameras();
      closeSettings();
    } catch (err) {
      alert(err.message || 'Failed to save');
    } finally {
      setIsSaving(false);
    }
  };

  const handleDelete = async (id) => {
    if (!window.confirm('Delete this camera?')) return;
    try {
      await api.delete(`/admin/cameras/${id}`);
      await fetchCameras();
      if (selected === id) closeSettings();
    } catch (err) {
      alert(err.message || 'Error deleting camera');
    }
  };

  // ── Upload Video ───────────────────────────────────────────────────────────
  const openUpload = () => { setShowUpload(true); setUploadFile(null); document.body.style.overflow = 'hidden'; };
  const closeUpload = () => { setShowUpload(false); setUploadFile(null); document.body.style.overflow = ''; };

  const handleUpload = async () => {
    if (!uploadFile) return alert('Please select an mp4 video file.');
    setIsSaving(true);
    try {
      const formData = new FormData();
      formData.append('video', uploadFile);

      const res = await api.post('/admin/cameras/upload-video', formData, {
        headers: { 'Content-Type': 'multipart/form-data' }
      });
      
      const videoUrl = res.data.url;

      // Automatically add it as a new Dummy Camera
      await api.post('/admin/cameras', {
        name:       'Test Video Camera',
        location:   'Virtual Upload',
        ip_address: null,
        stream_url: videoUrl,
        status:     'online',
        is_ai_enabled: true
      });

      await fetchCameras();
      closeUpload();
    } catch (err) {
      alert(err.message || 'Error uploading video');
    } finally {
      setIsSaving(false);
    }
  };

  // ── Preview Modal ──────────────────────────────────────────────────────────
  const openPreview = (cam) => { setPreviewId(cam.id); document.body.style.overflow = 'hidden'; };
  const closePreview = () => { setPreviewId(null); document.body.style.overflow = ''; };

  const handleToggle = async (id, currentStatus) => {
    if (!id) { alert('No camera selected!'); return; }
    try {
      setIsSaving(true);
      const res = await api.post(`/admin/cameras/${id}/toggle-status`);
      const newStatus = currentStatus === 'online' ? 'offline' : 'online';
      setEditForm(prev => ({ ...prev, status: newStatus }));
      await fetchCameras();
    } catch (err) {
      console.error('Toggle failed:', err);
      alert(err.message || `Failed to toggle status. Camera ID: ${id}`);
    } finally {
      setIsSaving(false);
    }
  };

  const formatTime = (d) => {
    if (!d) return 'No Activity';
    return new Date(d).toLocaleDateString() + ' ' + new Date(d).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
  };

  // ── Render ─────────────────────────────────────────────────────────────────
  return (
    <>
      <style>{`@keyframes spin { to { transform: rotate(360deg); } }`}</style>

      {/* Header */}
      <div className="page-header">
        <div className="page-title">
          <h1>Camera Management</h1>
          <p>Monitor and manage all security cameras</p>
        </div>
        <h1 className="page-title">Cameras & AI Streams</h1>
        <div style={{ display: 'flex', gap: '10px' }}>
          <button className="btn btn-primary" onClick={openAdd}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
            Add Camera
          </button>
          <button className="btn btn-outline" onClick={openUpload} style={{ borderColor: 'var(--primary-color)', color: 'var(--primary-color)' }}>
            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="17 8 12 3 7 8"></polyline><line x1="12" y1="3" x2="12" y2="15"></line></svg>
            Upload Video (Test Model)
          </button>
        </div>
      </div>

      {/* Stats */}
      <div className="stats-grid">
        <div className="stat-card"><div className="stat-value dark">{stats.total}</div><div className="stat-label">Total</div></div>
        <div className="stat-card"><div className="stat-value green">{stats.online}</div><div className="stat-label">Online</div></div>
        <div className="stat-card"><div className="stat-value red">{stats.offline}</div><div className="stat-label">Offline</div></div>
        <div className="stat-card"><div className="stat-value dark">{stats.total_alerts}</div><div className="stat-label">Total Alerts</div></div>
      </div>

      {/* Grid */}
      {isLoading ? (
        <div style={{ padding: '3rem', textAlign: 'center', color: 'var(--text-secondary)' }}>Loading cameras...</div>
      ) : cameras.length === 0 ? (
        <div style={{ padding: '3rem', textAlign: 'center', color: 'var(--text-secondary)' }}>
          No cameras yet. Click <strong>Add Camera</strong> to get started.
        </div>
      ) : (
        <div className="cameras-grid" style={{ opacity: selected ? 0.3 : 1, pointerEvents: selected ? 'none' : 'auto' }}>
          {[...cameras].sort((a, b) => a.id - b.id).map(cam => {
            const isOnline = cam.status === 'online';
            const streamUrl = cam.stream_url || buildStreamUrl(cam.ip_address);
            return (
              <div className="camera-card" key={cam.id}>
                {/* Feed */}
                <div className="camera-feed" style={{ position: 'relative', overflow: 'hidden' }}>
                  {isOnline && streamUrl ? (
                    <div style={{ position: 'absolute', inset: 0 }}>
                      <CameraStream url={streamUrl} height="100%" />
                    </div>
                  ) : (
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="1.5" strokeLinecap="round" strokeLinejoin="round">
                      <path d="M23 7l-7 5 7 5V7z"/><rect x="1" y="5" width="15" height="14" rx="2" ry="2"/>
                    </svg>
                  )}
                  <div className={`feed-badge ${isOnline ? 'live' : 'offline'}`}>
                    <div className="dot"/>{isOnline ? 'LIVE' : 'OFFLINE'}
                  </div>

                  {/* Live AI Violence Telemetry Bar */}
                  {cam.is_ai_enabled && !cam.is_entrance && isOnline && (
                    <div style={{ position: 'absolute', bottom: '10px', left: '10px', right: '10px', display: 'flex', flexDirection: 'column', gap: '4px', zIndex: 10 }}>
                      <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '10px', fontWeight: 'bold', color: '#fff', textShadow: '0 1px 3px rgba(0,0,0,0.9)', letterSpacing: '0.5px' }}>
                        <span>AI RISK LEVEL</span>
                        <span style={{ color: (cam.current_violence_score || 0) >= 0.70 ? '#ef4444' : (cam.current_violence_score || 0) >= 0.40 ? '#f59e0b' : '#10b981' }}>
                          {Math.round((cam.current_violence_score || 0) * 100)}%
                        </span>
                      </div>
                      <div style={{ width: '100%', height: '4px', background: 'rgba(255,255,255,0.2)', borderRadius: '2px', overflow: 'hidden' }}>
                        <div style={{
                          height: '100%',
                          width: `${(cam.current_violence_score || 0) * 100}%`,
                          background: (cam.current_violence_score || 0) >= 0.70 ? '#ef4444' : (cam.current_violence_score || 0) >= 0.40 ? '#f59e0b' : '#10b981',
                          transition: 'width 0.3s ease-out, background 0.3s ease-out',
                          boxShadow: (cam.current_violence_score || 0) >= 0.70 ? '0 0 8px #ef4444' : 'none'
                        }} />
                      </div>
                    </div>
                  )}

                </div>

                {/* Info */}
                <div className="camera-info">
                  <div className="camera-name">{cam.name}</div>
                  <div className="camera-location">{cam.location}</div>
                  {cam.ip_address && (
                    <div style={{ fontFamily: 'monospace', fontSize: '11px', color: 'var(--text-muted)', marginTop: '2px' }}>
                      {cam.ip_address}
                    </div>
                  )}
                </div>
                <div className="camera-status-row">
                  <span className="status-time">{formatTime(cam.last_active_at || cam.created_at)}</span>
                  <span className={`alerts-count ${(cam.total_alerts || 0) === 0 ? 'zero' : ''}`}>{cam.total_alerts || 0} alerts</span>
                </div>
                <div className="camera-footer" style={{ display: 'flex', gap: '8px' }}>
                  <button className="btn btn-primary" style={{ flex: 1, padding: '8px 12px', fontSize: '13px' }} onClick={() => openPreview(cam)}>
                    <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" style={{ marginRight: '6px' }}>
                      <polygon points="23 7 16 12 23 17 23 7"></polygon><rect x="1" y="5" width="15" height="14" rx="2" ry="2"></rect>
                    </svg>
                    Preview
                  </button>
                  <button className="btn btn-outline" style={{ width: '40px', padding: '0', display: 'flex', alignItems: 'center', justifyContent: 'center' }} onClick={() => openSettings(cam)} title="Settings">
                    <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2">
                      <circle cx="12" cy="12" r="3"/>
                      <path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06.06A1.65 1.65 0 0 0 4.68 15a1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06A1.65 1.65 0 0 0 9 4.68a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06A1.65 1.65 0 0 0 19.4 9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1z"/>
                    </svg>
                  </button>
                </div>
              </div>
            );
          })}
        </div>
      )}

      {/* ── ADD MODAL ── */}
      {showAdd && createPortal(
        <div className="modal-overlay open" onClick={e => { if (e.target === e.currentTarget) closeAdd(); }}>
          <div className="modal">
            <h2>Add New Camera</h2>

            <div className="form-group">
              <label>Camera Name *</label>
              <input type="text" placeholder="e.g. Camera 1 - Main Entrance"
                value={addForm.name} onChange={e => setAddForm({ ...addForm, name: e.target.value })} />
            </div>

            <div className="form-group">
              <label>Location *</label>
              <input type="text" placeholder="e.g. Building A - Floor 2"
                value={addForm.location} onChange={e => setAddForm({ ...addForm, location: e.target.value })} />
            </div>

            <div className="form-group">
              <label>IP Address or Video URL</label>
              <input type="text" placeholder="192.168.1.100  or  https://example.com/video.mp4"
                value={addForm.ip_address} onChange={e => setAddForm({ ...addForm, ip_address: e.target.value })} />
              {addForm.ip_address && (
                <small style={{ color: 'var(--text-muted)', fontSize: '11px' }}>
                  Stream: <code>{buildStreamUrl(addForm.ip_address)}</code>
                </small>
              )}
            </div>

            <div className="form-group">
              <label>Status</label>
              <div style={{ display: 'flex', gap: '10px' }}>
                {['online', 'offline'].map(s => (
                  <label key={s} style={{ display: 'flex', alignItems: 'center', gap: '6px', cursor: 'pointer', fontSize: '14px' }}>
                    <input type="radio" name="addStatus" value={s}
                      checked={addForm.status === s}
                      onChange={() => setAddForm({ ...addForm, status: s })} />
                    <span style={{ color: s === 'online' ? '#22c55e' : '#ef4444', textTransform: 'capitalize' }}>{s}</span>
                  </label>
                ))}
              </div>
            </div>

            <div className="modal-actions">
              <button className="btn btn-outline" onClick={closeAdd} disabled={isSaving}>Cancel</button>
              <button className="btn btn-primary" onClick={handleAdd} disabled={isSaving}>
                {isSaving ? 'Adding...' : 'Add Camera'}
              </button>
            </div>
          </div>
        </div>,
        document.body
      )}

      {/* ── UPLOAD VIDEO MODAL ── */}
      {showUpload && createPortal(
        <div className="modal-overlay open" onClick={e => { if (e.target === e.currentTarget) closeUpload(); }}>
          <div className="modal">
            <h2>Upload Video (Test Model)</h2>
            <p style={{ fontSize: '13px', color: 'var(--text-muted)', marginBottom: '20px' }}>
              Upload an MP4 video. It will be added as a virtual camera, and the edge worker will process its frames automatically.
            </p>

            <div className="form-group">
              <label>Select MP4 Video</label>
              <input type="file" accept="video/mp4,video/quicktime,video/x-msvideo" 
                onChange={e => setUploadFile(e.target.files[0])} />
            </div>

            <div className="modal-actions">
              <button className="btn btn-outline" onClick={closeUpload} disabled={isSaving}>Cancel</button>
              <button className="btn btn-primary" onClick={handleUpload} disabled={isSaving}>
                {isSaving ? 'Uploading...' : 'Upload & Add'}
              </button>
            </div>
          </div>
        </div>,
        document.body
      )}

      {/* ── SETTINGS MODAL ── */}
      {selectedCam && createPortal(
        <div className="modal-overlay open" onClick={e => { if (e.target === e.currentTarget) closeSettings(); }}>
          <div className="modal" style={{ width: '95vw', maxWidth: '1000px', maxHeight: '95vh', overflowY: 'auto' }}>
            <h2 style={{ marginBottom: '16px' }}>Camera Settings: {selectedCam.name}</h2>

            {/* Edit Fields */}
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '12px', marginTop: '16px' }}>
              <div className="form-group" style={{ margin: 0 }}>
                <label>Camera Name</label>
                <input type="text" value={editForm.name}
                  onChange={e => setEditForm({ ...editForm, name: e.target.value })} />
              </div>
              <div className="form-group" style={{ margin: 0 }}>
                <label>Location</label>
                <input type="text" value={editForm.location}
                  onChange={e => setEditForm({ ...editForm, location: e.target.value })} />
              </div>
              <div className="form-group" style={{ margin: 0, gridColumn: '1 / -1' }}>
                <label>IP Address</label>
                <input type="text" placeholder="192.168.1.100" value={editForm.ip_address}
                  onChange={e => setEditForm({ ...editForm, ip_address: e.target.value })} />
                {editForm.ip_address && (
                  <small style={{ color: 'var(--text-muted)', fontSize: '11px' }}>
                    Stream: <code>http://{editForm.ip_address}/video</code>
                  </small>
                )}
              </div>
            </div>

            <div style={{ display: 'flex', gap: '20px', marginTop: '12px', fontSize: '13px', color: 'var(--text-secondary)', alignItems: 'center' }}>
              <span>Status: <strong style={{ color: editForm.status === 'online' ? '#22c55e' : '#ef4444' }}>{editForm.status}</strong></span>
              <span>Alerts: <strong style={{ color: 'var(--text-primary)' }}>{selectedCam.total_alerts || 0}</strong></span>
            </div>

            <div className="modal-actions" style={{ marginTop: '16px' }}>
              <button className="btn btn-primary" onClick={handleSave} disabled={isSaving}>
                {isSaving ? 'Saving...' : 'Save Changes'}
              </button>
              <button className="btn btn-outline" onClick={() => handleToggle(selected, editForm.status)} disabled={isSaving}>
                {isSaving ? '...' : editForm.status === 'online' ? 'Go Offline' : 'Go Online'}
              </button>
              <button className="btn btn-outline" onClick={() => handleDelete(selected)}>🗑 Delete</button>
              <button className="btn btn-outline" onClick={closeSettings}>Close</button>
            </div>
          </div>
        </div>,
        document.body
      )}

      {/* ── PREVIEW MODAL ── */}
      {previewCam && createPortal(
        <div className="modal-overlay open" onClick={e => { if (e.target === e.currentTarget) closePreview(); }}>
          <div className="modal" style={{ width: '95vw', maxWidth: '1000px', maxHeight: '95vh', overflowY: 'auto', position: 'relative' }}>
            <h2 style={{ marginBottom: '12px' }}>{previewCam.name} - Live Preview</h2>

            <div style={{ position: 'relative', borderRadius: '12px', overflow: 'hidden' }}>
              {/* Live Stream — auto-detect */}
              <CameraStream
                url={previewCam.stream_url || buildStreamUrl(previewCam.ip_address)}
                height="500px"
              />

              {/* Live AI Violence Telemetry Bar (overlaid) */}
              {previewCam.is_ai_enabled && !previewCam.is_entrance && previewCam.status === 'online' && (
                <div style={{ position: 'absolute', bottom: '20px', left: '20px', right: '20px', display: 'flex', flexDirection: 'column', gap: '6px', zIndex: 10 }}>
                  <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: '14px', fontWeight: 'bold', color: '#fff', textShadow: '0 2px 4px rgba(0,0,0,0.9)', letterSpacing: '0.5px' }}>
                    <span>AI VIOLENCE RISK LEVEL</span>
                    <span style={{ color: (previewCam.current_violence_score || 0) >= 0.70 ? '#ef4444' : (previewCam.current_violence_score || 0) >= 0.40 ? '#f59e0b' : '#10b981' }}>
                      {Math.round((previewCam.current_violence_score || 0) * 100)}%
                    </span>
                  </div>
                  <div style={{ width: '100%', height: '8px', background: 'rgba(255,255,255,0.3)', borderRadius: '4px', overflow: 'hidden' }}>
                    <div style={{
                      height: '100%',
                      width: `${(previewCam.current_violence_score || 0) * 100}%`,
                      background: (previewCam.current_violence_score || 0) >= 0.70 ? '#ef4444' : (previewCam.current_violence_score || 0) >= 0.40 ? '#f59e0b' : '#10b981',
                      transition: 'width 0.3s ease-out, background 0.3s ease-out',
                      boxShadow: (previewCam.current_violence_score || 0) >= 0.70 ? '0 0 12px #ef4444' : 'none'
                    }} />
                  </div>
                </div>
              )}
            </div>

            <div className="modal-actions" style={{ marginTop: '20px' }}>
              <button className="btn btn-outline" onClick={closePreview}>Close Preview</button>
            </div>
          </div>
        </div>,
        document.body
      )}
    </>
  );
}

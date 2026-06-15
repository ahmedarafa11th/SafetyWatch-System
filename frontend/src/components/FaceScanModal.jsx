import React, { useState, useEffect, useRef } from 'react';
import { createPortal } from 'react-dom';

export default function FaceScanModal({ isOpen, actionType, onClose, onLogSuccess }) {
  const videoRef = useRef(null);
  const canvasRef = useRef(null);
  const [status, setStatus] = useState("Initializing camera...");
  const [stream, setStream] = useState(null);

  useEffect(() => {
    if (isOpen) {
      startCamera();
    } else {
      stopCamera();
    }
    return () => stopCamera();
  }, [isOpen]);

  const startCamera = async () => {
    try {
      setStatus("Starting camera...");
      const s = await navigator.mediaDevices.getUserMedia({ video: true });
      setStream(s);
      if (videoRef.current) {
        videoRef.current.srcObject = s;
      }
      setStatus("Scanning face...");
      // Start capturing frames every 3 seconds
      scanInterval.current = setInterval(captureAndIdentify, 3000);
    } catch (err) {
      console.error(err);
      setStatus("Error: Could not access camera.");
    }
  };

  const stopCamera = () => {
    if (stream) {
      stream.getTracks().forEach(track => track.stop());
      setStream(null);
    }
    if (scanInterval.current) {
      clearInterval(scanInterval.current);
    }
  };

  const scanInterval = useRef(null);

  const captureAndIdentify = async () => {
    if (!videoRef.current || !canvasRef.current) return;
    
    const context = canvasRef.current.getContext('2d');
    context.drawImage(videoRef.current, 0, 0, 320, 240);
    
    canvasRef.current.toBlob(async (blob) => {
      if (!blob) return;
      
      const formData = new FormData();
      formData.append('file', blob, 'frame.jpg');

      try {
        // 1. Recognize Face via Python API
        const recognizeRes = await fetch('http://localhost:8000/api/recognize', {
          method: 'POST',
          body: formData
        });
        
        const recognizeData = await recognizeRes.json();
        
        if (recognizeData.recognized) {
          setStatus(`Recognized: ${recognizeData.name}. Logging attendance...`);
          stopCamera(); // Stop scanning once recognized
          
          // 2. Log Attendance via Laravel API
          // Fetch token from sessionStorage or localStorage
          const token = sessionStorage.getItem('sw_token') || localStorage.getItem('sw_token') || '';
          
          const logRes = await fetch(`${import.meta.env.VITE_API_URL}/admin/attendance/log-via-face`, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'Authorization': `Bearer ${token}`,
              'Accept': 'application/json'
            },
            body: JSON.stringify({
              employee_code: recognizeData.employee_code,
              action: actionType
            })
          });
          
          const logData = await logRes.json();
          if (logRes.ok && logData.status) {
            setStatus(logData.message);
            setTimeout(() => {
              onLogSuccess(logData.message);
              onClose();
            }, 2000);
          } else {
            const backendError = logData.message || (logData.errors && logData.errors.employee_code && logData.errors.employee_code[0]) || "Failed to log attendance in database.";
            setStatus(backendError);
            // Resume scanning after 3s
            setTimeout(() => {
                setStatus("Scanning face...");
                startCamera();
            }, 3000);
          }
        }
      } catch (error) {
        console.error('Face API Error:', error);
        setStatus("Cannot connect to AI server. Retrying...");
      }
    }, 'image/jpeg');
  };

  if (!isOpen) return null;

  return createPortal(
    <div className="modal-overlay open">
      <div className="modal-box" style={{ textAlign: 'center' }}>
        <div className="modal-header">
          <h3>{actionType === 'check_in' ? 'Face Scan Check-In' : 'Face Scan Check-Out'}</h3>
          <button className="modal-close" onClick={onClose}>&times;</button>
        </div>
        <div className="modal-body">
          <p style={{ marginBottom: '10px', fontWeight: 'bold', color: 'inherit' }}>
            {status}
          </p>
          <div style={{ display: 'flex', justifyContent: 'center', marginBottom: '15px' }}>
            <video 
              ref={videoRef} 
              autoPlay 
              playsInline 
              muted 
              style={{ width: '100%', maxWidth: '320px', borderRadius: '8px', border: '2px solid #e2e8f0', backgroundColor: '#000' }}
            />
          </div>
          <canvas ref={canvasRef} width="320" height="240" style={{ display: 'none' }} />
          <button className="btn btn-outline" onClick={onClose} style={{ width: '100%' }}>Cancel</button>
        </div>
      </div>
    </div>,
    document.body
  );
}

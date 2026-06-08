import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import logoLight from '../assets/logo_v2.png';
import logoDark from '../assets/logo_v2_dark.png';
import heroMockup from '../assets/hero-mockup.png';

export default function LandingPage() {

  useEffect(() => {

  }, []);
  const [modalType, setModalType] = useState(null);

  useEffect(() => {
    const t = localStorage.getItem("theme") || "dark";
    document.documentElement.setAttribute("data-theme", t);
    document.documentElement.setAttribute("dir", "ltr");

    const link = document.createElement("link");
    link.href = "https://fonts.googleapis.com/css2?family=DM+Sans:wght@300;400;500;600;700&family=DM+Mono:wght@400;500&display=swap";
    link.rel = "stylesheet";
    document.head.appendChild(link);
    
    // Close modal on Escape key
    const handleEscape = (e) => {
      if (e.key === 'Escape') {
        closeModal();
      }
    };
    document.addEventListener('keydown', handleEscape);
    return () => document.removeEventListener('keydown', handleEscape);
  }, []);

  function toggleTheme() {
    const html = document.documentElement;
    const current = html.getAttribute("data-theme");
    const next = current === "light" ? "dark" : "light";
    html.setAttribute("data-theme", next);
    localStorage.setItem("theme", next);
  }

  function openModal(type) {
    setModalType(type);
    document.body.style.overflow = 'hidden';
  }

  function closeModal() {
    setModalType(null);
    document.body.style.overflow = '';
  }

  const handleModalOverlayClick = (e) => {
    if (e.target.classList.contains('modal-overlay')) {
      closeModal();
    }
  };

  return (
<>

{/*  NAV  */}
<nav>
    <Link to="/" className="logo" style={{ display: 'flex', alignItems: 'center', gap: '8px', textDecoration: 'none', fontSize: '22px', fontWeight: 'bold' }}>
      <img src={logoLight} alt="SafetyWatch Logo" className="logo-light-img" style={{ width: '28px', height: '28px', objectFit: 'contain' }} />
      <img src={logoDark} alt="SafetyWatch Logo" className="logo-dark-img" style={{ width: '28px', height: '28px', objectFit: 'contain', }} />
      <span>
        <span className="logo-text-1">Safety</span><span className="logo-text-2">Watch</span>
      </span>
    </Link>
  <ul>
    <li>
      <a href="#home">
        Home
      </a>
    </li>
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
    <li>
      <a style={{ opacity: 0.5, cursor: "not-allowed", pointerEvents: "none" }}>
        Demo
      </a>
    </li>
  </ul>
  <div className="nav-btns">
    <button className="theme-toggle" onClick={toggleTheme} title="Toggle light/dark mode">
      <svg className="icon-sun" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
        <circle cx="12" cy="12" r="5"></circle>
        <line x1="12" y1="1" x2="12" y2="3"></line>
        <line x1="12" y1="21" x2="12" y2="23"></line>
        <line x1="4.22" y1="4.22" x2="5.64" y2="5.64"></line>
        <line x1="18.36" y1="18.36" x2="19.78" y2="19.78"></line>
        <line x1="1" y1="12" x2="3" y2="12"></line>
        <line x1="21" y1="12" x2="23" y2="12"></line>
        <line x1="4.22" y1="19.78" x2="5.64" y2="18.36"></line>
        <line x1="18.36" y1="5.64" x2="19.78" y2="4.22"></line>
      </svg>
      <svg className="icon-moon" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" viewBox="0 0 24 24">
        <path d="M21 12.79A9 9 0 1 1 11.21 3 7 7 0 0 0 21 12.79z"></path>
      </svg>
    </button>
    <Link to="/login" style={{ textDecoration: "none" }}>
      <button className="btn-outline">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"></path>
          <polyline points="10 17 15 12 10 7"></polyline>
          <line x1="15" y1="12" x2="3" y2="12"></line>
        </svg>
        Login
      </button>
        </Link>
    <Link to="/signup" style={{ textDecoration: "none" }}>
      <button className="btn-primary">
        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"></path>
          <circle cx="9" cy="7" r="4"></circle>
          <line x1="19" y1="8" x2="19" y2="14"></line>
          <line x1="22" y1="11" x2="16" y2="11"></line>
        </svg>
        Sign Up
      </button>
        </Link>
  </div>
</nav>
{/*  HERO  */}
<div className="hero-section" id="home">
  <div className="hero container">
    <div className="hero-left fade-up">
      
      <h1>
        Enhancing Workplace Safety Using AI
      </h1>
      <p className="hero-subtitle">
        Real-time violence detection and automated attendance tracking
      </p>
      <p className="hero-desc">
        Enhance workplace safety with real-time violence detection and automated attendance tracking using AI-driven face recognition and monitoring solutions.
      </p>
      <div className="hero-btns">
        <a style={{ textDecoration: "none", opacity: 0.5, cursor: "not-allowed", pointerEvents: "none" }}>
          <button className="btn-hero-primary" disabled>
            <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
              <polygon points="5 3 19 12 5 21 5 3"></polygon>
            </svg>
            Live Demo
          </button>
        </a>
        <a href="#system-overview" style={{ textDecoration: "none" }}>
          <button className="btn-hero-secondary">
            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
              <rect x="3" y="3" width="7" height="7"></rect>
              <rect x="14" y="3" width="7" height="7"></rect>
              <rect x="14" y="14" width="7" height="7"></rect>
              <rect x="3" y="14" width="7" height="7"></rect>
            </svg>
            How It Works
          </button>
        </a>
      </div>
    </div>
    <div className="hero-right fade-up delay-2">
      <div className="hero-img-card">
        <img src={heroMockup} style={{ width: "100%", height: "100%", minHeight: "500px", objectFit: "cover", objectPosition: "center 30%", display: "block" }} />
      </div>
      <div className="badge-card badge-card-top">
        <div className="badge-icon badge-icon-alert">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#d97706" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
            <line x1="12" y1="9" x2="12" y2="13"></line>
            <line x1="12" y1="17" x2="12.01" y2="17"></line>
          </svg>
        </div>
        <div>
          <div>
            Alert System
          </div>
          <div className="badge-sub">
            Real-time
          </div>
        </div>
      </div>
      <div className="badge-card badge-card-bottom">
        <div className="badge-icon badge-icon-face">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="#3b6ef5" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
            <circle cx="12" cy="7" r="4"></circle>
          </svg>
        </div>
        <div>
          <div>
            Face Detection
          </div>
          <div className="badge-sub">
            98% Accuracy
          </div>
        </div>
      </div>
    </div>
  </div>
</div>
{/*  PROBLEM → SOLUTION  */}
<section className="problem-solution" id="problem-solution">
  <div className="container">
    <div className="section-header">
      <h2>
        Problem
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ margin: '0 10px', verticalAlign: 'middle' }}><line x1="5" y1="12" x2="19" y2="12"></line><polyline points="12 5 19 12 12 19"></polyline></svg>
        Solution
      </h2>
      <p>
        Traditional workplace monitoring systems face critical challenges that our AI-powered solution addresses
      </p>
    </div>
    <div className="ps-grid">
      <div className="ps-card ps-card-problem">
        <div className="ps-card-title">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" style={{ marginRight: '8px' }}><circle cx="12" cy="12" r="10"></circle><line x1="15" y1="9" x2="9" y2="15"></line><line x1="9" y1="9" x2="15" y2="15"></line></svg>
          Problem
        </div>
        <div className="ps-item">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#f97066" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" style={{ marginRight: '10px', flexShrink: 0, marginTop: '4px' }}><line x1="5" y1="12" x2="19" y2="12"></line></svg>
          Manual attendance is inefficient and prone to errors or fraud
        </div>
        <div className="ps-item">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#f97066" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" style={{ marginRight: '10px', flexShrink: 0, marginTop: '4px' }}><line x1="5" y1="12" x2="19" y2="12"></line></svg>
          Human monitoring of cameras is unreliable and mentally exhausting
        </div>
        <div className="ps-item">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#f97066" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" style={{ marginRight: '10px', flexShrink: 0, marginTop: '4px' }}><line x1="5" y1="12" x2="19" y2="12"></line></svg>
          Late detection of violent incidents leads to serious consequences
        </div>
      </div>
      <div className="ps-card ps-card-solution">
        <div className="ps-card-title">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round" style={{ marginRight: '8px' }}><path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"></path><polyline points="22 4 12 14.01 9 11.01"></polyline></svg>
          Our Solution
        </div>
        <div className="ps-item">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#3dd68c" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" style={{ marginRight: '10px', flexShrink: 0, marginTop: '4px' }}><polyline points="20 6 9 17 4 12"></polyline></svg>
          Face recognition attendance system with automatic logging
        </div>
        <div className="ps-item">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#3dd68c" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" style={{ marginRight: '10px', flexShrink: 0, marginTop: '4px' }}><polyline points="20 6 9 17 4 12"></polyline></svg>
          Automated violence detection with 24/7 AI monitoring
        </div>
        <div className="ps-item">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="#3dd68c" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round" style={{ marginRight: '10px', flexShrink: 0, marginTop: '4px' }}><polyline points="20 6 9 17 4 12"></polyline></svg>
          Real-time alerts and comprehensive violation logs
        </div>
      </div>
    </div>
  </div>
</section>

{/*  CORE FEATURES  */}
<section className="core-features" id="core-features">
  <div className="container">
    <div className="section-header">
      <h2>
        Core Features
      </h2>
      <p>
        Key functionalities demonstrating the practical implementation of our AI models
      </p>
    </div>
    <div className="features-grid">
      <div className="feature-card">
        <div className="feature-icon">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#3b6ef5" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"></path>
            <circle cx="12" cy="7" r="4"></circle>
          </svg>
        </div>
        <div className="feature-title">
          Face Recognition Attendance
        </div>
        <p className="feature-desc">
          Automatic employee identification and attendance logging using deep learning facial recognition
        </p>
      </div>
      <div className="feature-card">
        <div className="feature-icon">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#3b6ef5" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <path d="M23 7l-7 5 7 5V7z"></path>
            <rect x="1" y="5" width="15" height="14" rx="2" ry="2"></rect>
          </svg>
        </div>
        <div className="feature-title">
          Real-Time Camera Monitoring
        </div>
        <p className="feature-desc">
          24/7 live camera feed analysis with instant processing of video streams
        </p>
      </div>
      <div className="feature-card">
        <div className="feature-icon">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#3b6ef5" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
            <line x1="12" y1="9" x2="12" y2="13"></line>
            <line x1="12" y1="17" x2="12.01" y2="17"></line>
          </svg>
        </div>
        <div className="feature-title">
          Violence Detection & Alerts
        </div>
        <p className="feature-desc">
          AI-powered detection of aggressive behavior with immediate notification system
        </p>
      </div>
      <div className="feature-card">
        <div className="feature-icon">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#3b6ef5" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <line x1="18" y1="20" x2="18" y2="10"></line>
            <line x1="12" y1="20" x2="12" y2="4"></line>
            <line x1="6" y1="20" x2="6" y2="14"></line>
          </svg>
        </div>
        <div className="feature-title">
          Attendance & Violation Logs
        </div>
        <p className="feature-desc">
          Comprehensive dashboard with analytics, reports, and historical data tracking
        </p>
      </div>
    </div>
  </div>
</section>

{/*  SYSTEM OVERVIEW  */}
<section className="system-overview" id="system-overview">
  <div className="container">
    <div className="section-header">
      <h2>
        System Overview
      </h2>
      <p>
        End-to-end pipeline showing how data flows through our AI-powered safety system
      </p>
    </div>
    <div className="pipeline">
      <div className="feature-card pipeline-step">
        <div className="feature-icon">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#3b6ef5" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <path d="M23 7l-7 5 7 5V7z"></path>
            <rect x="1" y="5" width="15" height="14" rx="2" ry="2"></rect>
          </svg>
        </div>
        <div className="feature-title">
          Camera Feed
        </div>
        <p className="feature-desc" style={{ textAlign: "left" }}>
          Live CCTV streams and uploaded video files are continuously captured and fed into our system.
        </p>
      </div>
      <div className="pipeline-arrow">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ opacity: 0.5 }}><polyline points="9 18 15 12 9 6"></polyline></svg>
      </div>
      <div className="feature-card pipeline-step">
        <div className="feature-icon">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#3b6ef5" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <rect x="3" y="11" width="18" height="10" rx="2"></rect>
            <circle cx="12" cy="5" r="2"></circle>
            <path d="M12 7v4"></path>
            <line x1="8" y1="16" x2="8" y2="16"></line>
            <line x1="16" y1="16" x2="16" y2="16"></line>
            <path d="M5 11V9a7 7 0 0 1 14 0v2"></path>
          </svg>
        </div>
        <div className="feature-title">
          AI Models
        </div>
        <p className="feature-desc" style={{ textAlign: "left" }}>
          Dual CNN-based models process video frames simultaneously for face recognition and violence detection.
        </p>
      </div>
      <div className="pipeline-arrow">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ opacity: 0.5 }}><polyline points="9 18 15 12 9 6"></polyline></svg>
      </div>
      <div className="feature-card pipeline-step">
        <div className="feature-icon">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#3b6ef5" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <ellipse cx="12" cy="5" rx="9" ry="3"></ellipse>
            <path d="M21 12c0 1.66-4 3-9 3s-9-1.34-9-3"></path>
            <path d="M3 5v14c0 1.66 4 3 9 3s9-1.34 9-3V5"></path>
          </svg>
        </div>
        <div className="feature-title">
          Backend API
        </div>
        <p className="feature-desc" style={{ textAlign: "left" }}>
          RESTful API processes AI outputs, stores results securely, and triggers instant alerts upon threat detection.
        </p>
      </div>
      <div className="pipeline-arrow">
        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" style={{ opacity: 0.5 }}><polyline points="9 18 15 12 9 6"></polyline></svg>
      </div>
      <div className="feature-card pipeline-step">
        <div className="feature-icon">
          <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="#3b6ef5" strokeWidth="1.8" strokeLinecap="round" strokeLinejoin="round">
            <rect x="2" y="3" width="20" height="14" rx="2"></rect>
            <line x1="8" y1="21" x2="16" y2="21"></line>
            <line x1="12" y1="17" x2="12" y2="21"></line>
          </svg>
        </div>
        <div className="feature-title">
          Web Dashboard
        </div>
        <p className="feature-desc" style={{ textAlign: "left" }}>
          Real-time monitoring, analytics, and alert management interface for both administrators and employees.
        </p>
      </div>
    </div>
    
  </div>
</section>



{/*  FINAL CTA  */}
<section className="final-cta">
  <div className="container" style={{ textAlign: 'center', padding: '80px 20px', display: 'flex', flexDirection: 'column', alignItems: 'center' }}>
    <div className="section-header" style={{ marginBottom: '0' }}>
      <h2 className="text-gradient" style={{ marginBottom: '20px' }}>Ready to secure your workplace?</h2>
      <p style={{ marginBottom: '40px', maxWidth: '600px', margin: '0 auto 40px' }}>Join the next generation of workplace safety and automated monitoring today.</p>
    </div>
    <Link to="/signup" style={{ textDecoration: "none", display: "inline-block" }}>
      <button className="btn-primary" style={{ padding: '14px 36px', fontSize: '1.1rem', fontWeight: '600' }}>
        Get Started Now
      </button>
    </Link>
  </div>
</section>

{/*  FOOTER  */}
<footer>
  <div className="footer-grid">
    <div>
      <div className="footer-logo">
        <span>
          Safety
        </span>
        Watch
      </div>
      <div className="footer-tagline">
        AI-Powered Workplace Safety System
      </div>
    </div>
    <div className="footer-col">
      <h4>
        Project Information
      </h4>
      <p>
        Egyptian E-Learning University
        <br />
        Faculty of Information Technology
        <br />
        Academic Year: 2025-2026
      </p>
    </div>
    <div className="footer-col">
      <h4>
        Supervisors
      </h4>
      <p>
        Dr. Samar Hesham
        <br />
        Eng. Sara Hamdy
      </p>
    </div>
    <div style={{ display: "flex", alignItems: "flex-start", justifyContent: "flex-end", paddingTop: "4px" }}>
      <Link to="/login" style={{ textDecoration: "none" }}>
        <button className="btn-admin">
          <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
            <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"></path>
            <polyline points="10 17 15 12 10 7"></polyline>
            <line x1="15" y1="12" x2="3" y2="12"></line>
          </svg>
          Admin Login
        </button>
        </Link>
    </div>
  </div>
  <div className="footer-bottom">
    © 2026 SafetyWatch Graduation Project. All rights reserved.
  </div>
</footer>
{/*  MODALS  */}
<div className={`modal-overlay ${modalType ? "open" : ""}`} id="modal" onClick={handleModalOverlayClick}>
  <div className="modal modal-arch" id="modal-architecture" style={{ display: modalType === "architecture" ? "block" : "none" }}>
    <div className="modal-header">
      <h2>
        System Architecture Overview
      </h2>
      <button className="modal-close" onClick={closeModal}>
        ×
      </button>
    </div>
    {/*  1. Input: Camera Feed  */}
    <div className="arch-card arch-card-blue">
      <div className="arch-icon-badge arch-badge-blue">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#3b82f6" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <path d="M23 7l-7 5 7 5V7z"></path>
          <rect x="1" y="5" width="15" height="14" rx="2"></rect>
        </svg>
      </div>
      <div className="arch-card-content">
        <h4>
          Input: Camera Feed
        </h4>
        <p>
          Live CCTV video streams or uploaded video files are captured and sent to the processing pipeline. Supports multiple camera feeds simultaneously.
        </p>
      </div>
    </div>
    <div className="arch-chevron">
      ∨
    </div>
    {/*  2. AI: Detection Models  */}
    <div className="arch-card arch-card-purple">
      <div className="arch-icon-badge arch-badge-purple">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#9333ea" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <rect x="4" y="4" width="16" height="16" rx="2"></rect>
          <rect x="9" y="9" width="6" height="6"></rect>
          <line x1="9" y1="2" x2="9" y2="4"></line>
          <line x1="15" y1="2" x2="15" y2="4"></line>
          <line x1="9" y1="20" x2="9" y2="22"></line>
          <line x1="15" y1="20" x2="15" y2="22"></line>
          <line x1="2" y1="9" x2="4" y2="9"></line>
          <line x1="2" y1="15" x2="4" y2="15"></line>
          <line x1="20" y1="9" x2="22" y2="9"></line>
          <line x1="20" y1="15" x2="22" y2="15"></line>
        </svg>
      </div>
      <div className="arch-card-content">
        <h4>
          AI: Detection Models (CNN)
        </h4>
        <p>
          Dual CNN-based models process video frames for face recognition and violence detection.
        </p>
        <div className="arch-two-col">
          <div className="arch-sub-cell">
            <strong>
              Face Recognition
            </strong>
            <span>
              FaceNet + VGGFace2
            </span>
          </div>
          <div className="arch-sub-cell">
            <strong>
              Violence Detection
            </strong>
            <span>
              CNN-LSTM Hybrid
            </span>
          </div>
        </div>
      </div>
    </div>
    <div className="arch-chevron">
      ∨
    </div>
    {/*  3. Backend: API Processing  */}
    <div className="arch-card arch-card-blue">
      <div className="arch-icon-badge arch-badge-darkblue">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#1e40af" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <polygon points="12 2 2 7 12 12 22 7 12 2"></polygon>
          <polyline points="2 17 12 22 22 17"></polyline>
          <polyline points="2 12 12 17 22 12"></polyline>
        </svg>
      </div>
      <div className="arch-card-content">
        <h4>
          Backend: API Processing
        </h4>
        <p>
          RESTful API processes AI model outputs, stores results in database, and triggers alerts when threats are detected.
        </p>
        <div className="arch-bullets">
          <div className="arch-bullet">
            → Attendance logging & timestamp recording
          </div>
          <div className="arch-bullet">
            → Violation detection & alert generation
          </div>
          <div className="arch-bullet">
            → Data storage & retrieval (PostgreSQL)
          </div>
        </div>
      </div>
    </div>
    <div className="arch-chevron">
      ∨
    </div>
    {/*  4. Output: Dashboard & Alerts  */}
    <div className="arch-card arch-card-green">
      <div className="arch-icon-badge arch-badge-green">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#16a34a" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
          <rect x="3" y="3" width="7" height="7"></rect>
          <rect x="14" y="3" width="7" height="7"></rect>
          <rect x="14" y="14" width="7" height="7"></rect>
          <rect x="3" y="14" width="7" height="7"></rect>
        </svg>
      </div>
      <div className="arch-card-content">
        <h4>
          Output: Dashboard & Alerts
        </h4>
        <p>
          Web dashboard provides real-time monitoring, analytics, and alert management for admins and employees.
        </p>
        <div className="arch-two-col">
          <div className="arch-sub-cell">
            <strong>
              Admin View
            </strong>
            <span>
              Full system control
            </span>
          </div>
          <div className="arch-sub-cell">
            <strong>
              Employee View
            </strong>
            <span>
              Personal attendance
            </span>
          </div>
        </div>
      </div>
    </div>
    <div className="arch-chevron">
      ∨
    </div>
    {/*  5. Technology Stack  */}
    <div className="arch-tech-card">
      <h4>
        Technology Stack
      </h4>
      <div className="arch-tech-grid">
        <div className="arch-tech-item">
          <strong>
            Frontend
          </strong>
          <span>
            React + Tailwind
          </span>
        </div>
        <div className="arch-tech-item">
          <strong>
            Backend
          </strong>
          <span>
            Python + Flask
          </span>
        </div>
        <div className="arch-tech-item">
          <strong>
            AI/ML
          </strong>
          <span>
            TensorFlow + PyTorch
          </span>
        </div>
        <div className="arch-tech-item">
          <strong>
            Database
          </strong>
          <span>
            PostgreSQL
          </span>
        </div>
      </div>
    </div>
  </div>
</div>



</>
  );
}


# SafetyWatch Flutter App Implementation Plan

This document outlines the step-by-step technical implementation plan for building the SafetyWatch Flutter App based on the provided UI/UX web designs. It emphasizes strict adherence to Clean Architecture, advanced Riverpod state management, scalable AI integration, and robust performance strategies suitable for a production-grade graduation project.

## Goal
To convert the "SafetyWatch" web design into a fully functional, mobile-optimized, and responsive Android Flutter application. While preserving the web design's core identity (exact colors, typography, style, and structure), the layout will be intelligently adapted for mobile usability. The app will feature full Dark/Light mode support, robust Clean Architecture, and AI-ready backend connections.

## User Review Required
> [!IMPORTANT]
> The scope focuses heavily on architecture enforcement alongside UI features. I have broken down the implementation into phases. Please review the updated architectural rules, the integration of the AI Layer, and let me know your thoughts before I proceed to Phase 1.

## Proposed Changes

### **[NEW] Architecture Consistency Rules (STRICT)**
- **UI → Calls Providers:** No business logic inside UI.
- **Providers → Call UseCases:** Providers manage state based on UseCase outcomes.
- **UseCases → Call Repositories:** Domain layer dictates business rules.
- **Repositories → Call Data Sources:** Data layer interacts with network and local storage.
- **FORBIDDEN:** UI calling repositories directly or bypassing UseCases.

### Phase 1: Project Initialization, Core Infrastructure, & Error Handling
- Create the Flutter project (`safetywatch_app`).
- Add core dependencies: `flutter_riverpod`, `go_router`, `dio`, `freezed_annotation`, `json_annotation`, `google_fonts`, `flutter_svg`.
- Add caching/storage dependencies: `shared_preferences` (or `hive`), `flutter_secure_storage`.
- Add dev dependencies: `build_runner`, `freezed`, `json_serializable`.
- Set up the Clean Architecture folder structure (`lib/core`, `lib/features`).
- Implement `core/theme` (Light/Dark mode using the exact hex codes from `style-dark.css`, adapted for mobile readability).
- **[NEW] Dependency Injection System (MANDATORY):** Create `core/di/providers.dart`. All core services, repositories, and data sources MUST be injected via Riverpod. Direct instantiation inside features is strictly forbidden.
- Global Error Handling: Create `core/errors/exceptions.dart` and `core/errors/failures.dart`. Standardize API response handling and data layer failure mapping.
- **[NEW] Caching Strategy & Offline Mode Strategy:** Define local caching services (using `flutter_secure_storage` for tokens, and `shared_preferences` for fast-access local configs). Define behavior for network failures to fallback to cached data, show "Offline Mode" UI indicators, and prevent crashes.
- **[NEW] Demo Mode System Setup (IMPORTANT):** Implement a global "Demo Mode" toggle provider to allow switching between the real backend and simulated fake data (useful for presentations offline).

### Phase 2: Navigation Architecture (Advanced GoRouter)
- Advanced Routing Setup: Use `GoRouter` with `ShellRoute` to maintain consistent Shell (Bottom Nav Bar / Drawer) for dashboard and log screens.
- **[NEW] Role-Based Access Control (RBAC):** Extend the Auth model to include Admin and Employee roles. Add GoRouter AuthGuards to restrict screens/features natively based on these roles.
- Define routes for all 11 screens (Landing, Auth, Dashboards, Logs, Alerts, Cameras, Employees).

### Phase 3: Core Providers & Network Layer (Dio)
- Create the base `Dio` network client in `core/network`.
- Interceptors: Set up Dio Interceptors to seamlessly handle auth tokens, logging, and global HTTP error handling.
- Setup a Theme Provider (`StateNotifierProvider`) to manage light/dark mode toggles.

### Phase 4: Feature Implementation - Auth
- **Riverpod Enforcement (STRICT):** 
  - Each feature folder MUST include: `state.dart` (Freezed models), `notifier.dart` (logic), and `provider.dart` (DI).
  - Use `AsyncNotifierProvider` for API-dependent fetching and `StateNotifierProvider` for local UI state.
- **Data Layer:** Auth Models, Auth DataSource, Auth Repository Impl.
- **Domain Layer:** Auth Repository Interface, Login/Signup UseCases.
- **Presentation Layer:** Login Screen, Signup Screen, Auth Notifier. Handle loading, success, and error states gracefully.

### Phase 5: Feature Implementation - Landing Page & UI/UX Adaptation
- Build the `safetywatch.html` layout content (Hero, Architecture, Demo, AI Models, Team).
- UI/UX Adaptation: Use `LayoutBuilder` and `MediaQuery` to transform horizontal web components into mobile-friendly stacks or grids. Ensure padding and touch targets meet mobile accessibility guidelines.
- **[NEW] Performance Optimization (Final Layer):** Enforce `const` constructors wherever possible to prevent unnecessary rebuilds.

### Phase 6: Dashboards & Shared UI Components
- Implement the Admin and Employee Dashboards.
- Loading & Caching UX: Implement Shimmer effects/Skeleton loaders for all asynchronous dashboard data widgets instead of blank CircularProgressIndicators. Cache initial responses for immediate rendering.
- **[NEW] Performance Optimization (Final Layer):** Use Riverpod `.select()` extensively when passing parameters to reduce rebuilds.

### Phase 7: Remaining Features (Logs, Alerts, Cameras, Employees)
- Implement Attendance screens, Violation screens, and Security Alert screens.
- Implement Camera Management screen and Employees directory.
- **[NEW] Performance Optimization (Final Layer):** Implement Lazy Loading and a robust Pagination strategy for large dataset lists (e.g., Logs, Alerts).

### Phase 8: AI Integration Layer (MANDATORY)
- AI Service Abstraction Layer: Define dedicated architectural boundaries in an `ai_vision` feature targeting future ML/CV endpoints, ensuring it is plug-and-play for future models.
- Data Models: Create Freezed models for detection results, confidence scores, and real-time alert structures.
- **[NEW] Real-time Data Integration (CRITICAL):** Extend the WebSocket/gRPC layer. Define `StreamProvider` or integrate streams into `AsyncNotifier` for live real-time updates of Alerts and Dashboard metrics, maintaining strict lifecycle stream management.
- **[NEW] AI Layer Completion (Clean Architecture):** Add Domain UseCases such as `get_detection_results.dart` and `subscribe_to_alerts.dart`. Ensure the UI interacts ONLY through these UseCases.
- **[NEW] Demo Mode Simulation:** Integrate Simulated AI detections and Fake real-time alerts specifically built for presentation purposes offline.

## Open Questions
> [!WARNING]
> 1. For data caching, `flutter_secure_storage` will be used for tokens. Do you prefer `Hive` over `shared_preferences` for aggressively caching large lists (like Alert Logs or Attendance)?
> 2. What name should I use for the Flutter project directory? (e.g., `safetywatch_app`)

## Verification Plan
### Automated Tests
- **[NEW] Enhanced Testing Strategy:** Implement Mock API layers for scalable testing.
- Unit Tests: Test Domain UseCases and Provider Notifiers using `flutter_test` and `mockito`/`mocktail`.
- Widget Tests: Write widget tests for critical user flows (Login screen validation and Dashboard layout structure).
- **[NEW] Integration Tests:** Add at least ONE end-to-end integration test covering the complete Login → Dashboard flow.
- Run `flutter analyze` ensuring zero warnings or lints violated. Ensure BuildRunner generates all Freezed classes successfully.
### Manual Verification
- Visual inspection of the UI components simulating dark/light mode toggles.
- Verify Shimmer loading behavior by simulating artificially delayed API calls inside Providers.

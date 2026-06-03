import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const LoginScreen({super.key, required this.onToggleTheme});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String role = "employee";
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool obscure = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void login() {
    if (role == "admin") {
      Navigator.pushReplacementNamed(context, '/admin');
    } else {
      Navigator.pushReplacementNamed(context, '/employee');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo - Eye icon from asset
                Icon(
                  Icons.visibility,
                  size: 48,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                const SizedBox(height: 16),
                const Text(
                  "SafetyWatch",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  "Workplace Safety Monitoring System",
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
                const SizedBox(height: 40),

                // Card
                Container(
                  constraints: const BoxConstraints(maxWidth: 440),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(isDark ? 40 : 10),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Sign In",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: "Email",
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: obscure,
                        decoration: InputDecoration(
                          labelText: "Password",
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(obscure ? Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => obscure = !obscure),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Role selector
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => role = "employee"),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: role == "employee"
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: role == "employee"
                                        ? AppColors.primary
                                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                  ),
                                ),
                                child: Text(
                                  "Employee",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: role == "employee"
                                        ? Colors.white
                                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => role = "admin"),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: role == "admin"
                                      ? AppColors.primary
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: role == "admin"
                                        ? AppColors.primary
                                        : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                                  ),
                                ),
                                child: Text(
                                  "Admin",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: role == "admin"
                                        ? Colors.white
                                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: login,
                          child: const Text("Sign In", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/signup'),
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                // Theme toggle
                IconButton(
                  onPressed: widget.onToggleTheme,
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

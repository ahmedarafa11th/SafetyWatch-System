import 'package:flutter/material.dart';
import '../core/app_colors.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const SignupScreen({super.key, required this.onToggleTheme});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  String role = 'employee';
  bool obscurePassword = true;
  bool obscureConfirm = true;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void createAccount() {
    // Navigate to login after sign up
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      // Top AppBar
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.darkBg : Colors.white,
        surfaceTintColor: Colors.transparent,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12),
          child: Row(
            children: [
              Icon(Icons.visibility, size: 22,
                  color: isDark ? Colors.white : const Color(0xFF1E293B)),
            ],
          ),
        ),
        title: const Text(
          'SafetyWatch',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        titleSpacing: 0,
        actions: [
          IconButton(
            icon:
                Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 20),
            onPressed: widget.onToggleTheme,
          ),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            icon: const Icon(Icons.login, size: 18),
            label: const Text('Login',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Sign Up',
                  style:
                      TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Header
                const Text(
                  'Create Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join SafetyWatch',
                  style: TextStyle(fontSize: 15, color: secondaryText),
                ),
                const SizedBox(height: 32),

                // Form Card
                Container(
                  width: double.infinity,
                  constraints: const BoxConstraints(maxWidth: 440),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder,
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
                      // Role Toggle
                      Container(
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkBg
                              : AppColors.lightBg,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _roleTab(
                              isDark: isDark,
                              icon: Icons.person_outline,
                              label: 'Sign up as Employee',
                              selected: role == 'employee',
                              onTap: () =>
                                  setState(() => role = 'employee'),
                            ),
                            const SizedBox(width: 4),
                            _roleTab(
                              isDark: isDark,
                              icon: Icons.admin_panel_settings_outlined,
                              label: 'Sign up as Admin',
                              selected: role == 'admin',
                              onTap: () =>
                                  setState(() => role = 'admin'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Full Name
                      _fieldLabel('Full Name'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter your full name',
                          prefixIcon: Icon(Icons.person_outline, size: 20),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Email
                      _fieldLabel('Email'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: 'Enter your email',
                          prefixIcon: Icon(Icons.email_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Password
                      _fieldLabel('Password'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        decoration: InputDecoration(
                          hintText: 'Create a password',
                          prefixIcon:
                              const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => obscurePassword = !obscurePassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Confirm Password
                      _fieldLabel('Confirm Password'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: confirmController,
                        obscureText: obscureConfirm,
                        decoration: InputDecoration(
                          hintText: 'Confirm your password',
                          prefixIcon:
                              const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => obscureConfirm = !obscureConfirm),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Create Account Button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: createAccount,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Create Account',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                // Sign in link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: TextStyle(color: secondaryText),
                    ),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: const Text(
                        'Sign In',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _roleTab({
    required bool isDark,
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? (isDark ? AppColors.darkCard : Colors.white)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: selected
                ? Border.all(color: AppColors.primary, width: 1.5)
                : null,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withAlpha(30),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: selected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected ? AppColors.primary : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/app_colors.dart';
import '../providers/auth_provider.dart';

// Password strength checker — ported from web frontend
class _PasswordStrength {
  final bool hasLength;
  final bool hasUppercase;
  final bool hasLowercase;
  final bool hasNumber;
  final bool hasSpecial;

  _PasswordStrength(String pwd)
      : hasLength = pwd.length >= 8,
        hasUppercase = RegExp(r'[A-Z]').hasMatch(pwd),
        hasLowercase = RegExp(r'[a-z]').hasMatch(pwd),
        hasNumber = RegExp(r'[0-9]').hasMatch(pwd),
        hasSpecial = RegExp(r'[!@#$%^&*()_+\-=\[\]{};:"|,.<>/?\\]').hasMatch(pwd);

  int get score =>
      [hasLength, hasUppercase, hasLowercase, hasNumber, hasSpecial]
          .where((b) => b)
          .length;

  bool get allMet => score == 5;

  String get label =>
      ['', 'Very Weak', 'Weak', 'Fair', 'Strong', 'Very Strong'][score];

  Color get color => [
        Colors.transparent,
        const Color(0xFFEF4444),
        const Color(0xFFF97316),
        const Color(0xFFEAB308),
        const Color(0xFF22C55E),
        const Color(0xFF16A34A),
      ][score];
}

class SignupScreen extends ConsumerStatefulWidget {
  final VoidCallback onToggleTheme;
  const SignupScreen({super.key, required this.onToggleTheme});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  String role = 'employee';
  bool obscurePassword = true;
  bool obscureConfirm = true;
  bool _isLoading = false;
  bool _success = false;
  String? _error;

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    passwordController.addListener(() => setState(() {}));
    confirmController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  _PasswordStrength get _strength => _PasswordStrength(passwordController.text);

  bool get _passwordsMatch =>
      passwordController.text.isNotEmpty &&
      confirmController.text.isNotEmpty &&
      passwordController.text == confirmController.text;

  bool get _canSubmit =>
      nameController.text.isNotEmpty &&
      emailController.text.isNotEmpty &&
      _strength.allMet &&
      _passwordsMatch &&
      !_isLoading &&
      !_success;

  Future<void> _createAccount() async {
    setState(() {
      _error = null;
    });

    if (nameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmController.text.isEmpty) {
      setState(() => _error = 'Please fill in all fields.');
      return;
    }
    if (!_strength.allMet) {
      setState(() => _error = 'Password does not meet the required criteria.');
      return;
    }
    if (!_passwordsMatch) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() => _isLoading = true);

    final authNotifier = ref.read(authProvider.notifier);
    final result = await authNotifier.register(
      nameController.text,
      emailController.text.trim().toLowerCase(),
      passwordController.text,
      role,
    );

    if (!mounted) return;

    setState(() => _isLoading = false);

    if (result.success) {
      setState(() => _success = true);
    } else {
      setState(
          () => _error = result.message ?? 'Registration failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryText =
        isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Icon(
                  Icons.visibility,
                  size: 48,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                const SizedBox(height: 16),

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
                      SizedBox(
                        width: double.infinity,
                        child: SegmentedButton<String>(
                          segments: const [
                            ButtonSegment<String>(
                              value: 'employee',
                              label: Text('Employee'),
                              icon: Icon(Icons.person_outline),
                            ),
                            ButtonSegment<String>(
                              value: 'admin',
                              label: Text('Admin'),
                              icon: Icon(Icons.admin_panel_settings_outlined),
                            ),
                          ],
                          selected: {role},
                          onSelectionChanged: (Set<String> newSelection) {
                            setState(() {
                              role = newSelection.first;
                            });
                          },
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Error message
                      if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.withAlpha(80)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: Colors.redAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _error!,
                                  style: const TextStyle(
                                    color: Colors.redAccent,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Success message (pending approval)
                      if (_success)
                        Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withAlpha(25),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: const Color(0xFF22C55E).withAlpha(80)),
                          ),
                          child: Column(
                            children: [
                              const Text(
                                '✅ Account created! Your account is pending admin approval. You will be able to log in once an admin activates your account.',
                                style: TextStyle(
                                  color: Color(0xFF4ADE80),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 40,
                                child: OutlinedButton(
                                  onPressed: () => Navigator.pushReplacementNamed(
                                      context, '/login'),
                                  style: OutlinedButton.styleFrom(
                                    side: const BorderSide(
                                        color: Color(0xFF4ADE80)),
                                    foregroundColor: const Color(0xFF4ADE80),
                                  ),
                                  child: const Text('Go to Login'),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // Full Name
                      _fieldLabel('Full Name'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Enter your full name',
                          prefixIcon: const Icon(Icons.person_outline, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Email
                      _fieldLabel('Email'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Enter your email address',
                          prefixIcon: const Icon(Icons.email_outlined, size: 20),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Password with show/hide
                      _fieldLabel('Password'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: obscurePassword,
                        textInputAction: TextInputAction.next,
                        decoration: InputDecoration(
                          hintText: 'Create a strong password',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
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
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      // Password strength bar
                      if (passwordController.text.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Row(
                          children: List.generate(
                            5,
                            (i) => Expanded(
                              child: Container(
                                height: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 2),
                                decoration: BoxDecoration(
                                  color: i < _strength.score
                                      ? _strength.color
                                      : (isDark
                                          ? Colors.white.withAlpha(25)
                                          : Colors.black.withAlpha(25)),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _strength.label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _strength.color,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Criteria checklist
                        ...[
                          _criteriaRow('At least 8 characters', _strength.hasLength),
                          _criteriaRow('One uppercase letter (A-Z)', _strength.hasUppercase),
                          _criteriaRow('One lowercase letter (a-z)', _strength.hasLowercase),
                          _criteriaRow('One number (0-9)', _strength.hasNumber),
                          _criteriaRow('One special character (!@#\$%)', _strength.hasSpecial),
                        ],
                      ],
                      const SizedBox(height: 18),

                      // Confirm Password with match indicator
                      _fieldLabel('Confirm Password'),
                      const SizedBox(height: 8),
                      TextField(
                        controller: confirmController,
                        obscureText: obscureConfirm,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) {
                          if (_canSubmit) _createAccount();
                        },
                        decoration: InputDecoration(
                          hintText: 'Confirm your password',
                          prefixIcon: const Icon(Icons.lock_outline, size: 20),
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (confirmController.text.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(right: 4),
                                  child: Icon(
                                    _passwordsMatch
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: _passwordsMatch
                                        ? const Color(0xFF22C55E)
                                        : const Color(0xFFEF4444),
                                    size: 20,
                                  ),
                                ),
                              IconButton(
                                icon: Icon(
                                  obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => obscureConfirm = !obscureConfirm),
                              ),
                            ],
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: confirmController.text.isNotEmpty
                                  ? (_passwordsMatch
                                      ? const Color(0xFF22C55E).withAlpha(128)
                                      : const Color(0xFFEF4444).withAlpha(128))
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Create Account Button
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _canSubmit ? _createAccount : null,
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Creating Account…',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600)),
                                  ],
                                )
                              : const Text(
                                  'Create Account',
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w600),
                                ),
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
                      'Already have an account? ',
                      style: TextStyle(color: secondaryText),
                    ),
                    InkWell(
                      onTap: () =>
                          Navigator.pushReplacementNamed(context, 'login'),
                      borderRadius: BorderRadius.circular(4),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        child: Text(
                          'Sign In',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                IconButton(
                  onPressed: widget.onToggleTheme,
                  icon: Icon(
                    isDark ? Icons.light_mode : Icons.dark_mode,
                    color: secondaryText,
                  ),
                ),
              ],
            ),
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

  Widget _criteriaRow(String label, bool met) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(
            met ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: met ? const Color(0xFF4ADE80) : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: met ? const Color(0xFF4ADE80) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

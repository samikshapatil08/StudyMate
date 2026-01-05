import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../blocs/auth/auth_bloc.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

  String? get passwordError {
    final password = passwordController.text;
    if (password.isEmpty) return null;

    if (password.length < 8) {
      return "Password must be at least 8 characters long";
    }

    bool hasUppercase = false;
    bool hasDigits = false;
    bool hasSpecial = false;
    const String specialCharsList = '!@#\$%^&*(),.?":{}|<>';

    for (int i = 0; i < password.length; i++) {
      String char = password[i];

      if (char.toUpperCase() == char && char.toLowerCase() != char) {
        hasUppercase = true;
      } else if ("0123456789".contains(char)) {
        hasDigits = true;
      } else if (specialCharsList.contains(char)) {
        hasSpecial = true;
      }
    }

    if (!hasUppercase) return "Password must contain an uppercase letter";
    if (!hasDigits) return "Password must contain a number";
    if (!hasSpecial) return "Password must contain a special character";

    return null;
  }

  String? get confirmPasswordError {
    if (confirmPasswordController.text.isEmpty) return null;
    if (passwordController.text != confirmPasswordController.text) {
      return "Passwords do not match";
    }
    return null;
  }

  bool get isFormValid {
    return emailController.text.trim().isNotEmpty &&
        passwordError == null &&
        passwordController.text.isNotEmpty &&
        confirmPasswordError == null &&
        confirmPasswordController.text.isNotEmpty;
  }

  void _signup() {
    if (!isFormValid) return;
    context.read<AuthBloc>().add(
          AuthSignupRequested(
            emailController.text,
            passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Create Account",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            Navigator.pop(context);
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          final authError = state is AuthError ? state.message : '';

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Sign Up",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: passwordController,
                        obscureText: !showPassword,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: "Password",
                          errorText: passwordError,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(showPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () =>
                                setState(() => showPassword = !showPassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: confirmPasswordController,
                        obscureText: !showConfirmPassword,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          errorText: confirmPasswordError,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                          suffixIcon: IconButton(
                            icon: Icon(showConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () => setState(() =>
                                showConfirmPassword = !showConfirmPassword),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (authError.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            authError,
                            style: GoogleFonts.inter(
                                color: AppTheme.accentRed, fontSize: 13),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      SizedBox(
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFormValid
                                ? AppTheme.primaryPurple
                                : AppTheme.textSecondary,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: isFormValid && !isLoading ? _signup : null,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  "Create Account",
                                  style: GoogleFonts.inter(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

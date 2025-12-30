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
  final TextEditingController confirmPasswordController = TextEditingController();

  bool showPassword = false;
  bool showConfirmPassword = false;

  String get passwordStrength {
    final password = passwordController.text;
    if (password.length < 6) return "Weak";
    if (password.length < 10) return "Medium";
    return "Strong";
  }

  Color get strengthColor {
    switch (passwordStrength) {
      case "Medium": return AppTheme.accentYellow;
      case "Strong": return AppTheme.accentGreen;
      default: return AppTheme.accentRed;
    }
  }

  bool get isFormValid {
    return emailController.text.trim().isNotEmpty &&
        passwordController.text.length >= 6 &&
        passwordController.text == confirmPasswordController.text;
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
    final theme = Theme.of(context); // ✅

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // ✅
      appBar: AppBar(
        title: Text(
          "Create Account",
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: theme.textTheme.bodyLarge?.color, // ✅
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
          final error = state is AuthError ? state.message : '';

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.cardColor, // ✅
                  borderRadius: BorderRadius.circular(20),
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
                        color: theme.textTheme.bodyLarge?.color, // ✅
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: GoogleFonts.inter(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    TextField(
                      controller: passwordController,
                      obscureText: !showPassword,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: "Password",
                        labelStyle: GoogleFonts.inter(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        Text(
                          "Strength: ",
                          style: GoogleFonts.inter(
                            color: theme.textTheme.bodyMedium?.color, // ✅
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          passwordStrength,
                          style: GoogleFonts.inter(
                            color: strengthColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: confirmPasswordController,
                      obscureText: !showConfirmPassword,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        labelText: "Confirm Password",
                        labelStyle: GoogleFonts.inter(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            showConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              showConfirmPassword = !showConfirmPassword;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (error.isNotEmpty)
                      Text(
                        error,
                        style: GoogleFonts.inter(
                          color: AppTheme.accentRed,
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),

                    const SizedBox(height: 20),

                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFormValid
                              ? AppTheme.primaryPurple
                              : AppTheme.textSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: isFormValid && !isLoading ? _signup : null,
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(
                                "Create Account",
                                style: GoogleFonts.inter(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
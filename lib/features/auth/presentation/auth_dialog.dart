import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/core/utils/theme.dart';
import 'package:truce/features/auth/presentation/auth_cubit.dart';

class AuthDialog extends StatefulWidget {
  const AuthDialog({super.key});

  @override
  State<AuthDialog> createState() => _AuthDialogState();
}

class _AuthDialogState extends State<AuthDialog> {
  bool isLogin = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: BlocConsumer<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated || state is AuthGuest) {
              Navigator.pop(context);
            }
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.red),
              );
            }
          },
          builder: (context, state) {
            if (state is AuthLoading) {
              return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isLogin ? 'Login | تسجيل الدخول' : 'Sign Up | إنشاء حساب',
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: TruceTheme.primary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email | البريد الإلكتروني'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password | كلمة المرور'),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (isLogin) {
                      context.read<AuthCubit>().signIn(_emailController.text, _passwordController.text);
                    } else {
                      context.read<AuthCubit>().signUp(_emailController.text, _passwordController.text);
                    }
                  },
                  child: Text(isLogin ? 'Login' : 'Sign Up'),
                ),
                TextButton(
                  onPressed: () => setState(() => isLogin = !isLogin),
                  child: Text(isLogin ? 'New user? Sign Up' : 'Already have an account? Login'),
                ),
                const Divider(),
                OutlinedButton.icon(
                  onPressed: () => context.read<AuthCubit>().signInWithGoogle(),
                  icon: const Icon(Icons.g_mobiledata),
                  label: const Text('Continue with Google'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    context.read<AuthCubit>().continueAsGuest();
                  },
                  child: const Text('Cancel / Continue as Guest', style: TextStyle(color: Colors.grey)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

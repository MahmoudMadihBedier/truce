import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/features/auth/presentation/auth_cubit.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Truce Egypt - Login')),
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) return const Center(child: CircularProgressIndicator());

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Welcome to Truce', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const Text('Track prices in Egypt accurately'),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () => context.read<AuthCubit>().signInAsGuest(),
                  child: const Text('Continue as Guest'),
                ),
                TextButton(
                  onPressed: () {}, // Google Sign in placeholder
                  child: const Text('Sign in with Google'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

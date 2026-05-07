import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:truce/core/di/injection.dart' as di;
import 'package:truce/core/utils/theme.dart';
import 'package:truce/features/auth/presentation/auth_cubit.dart';
import 'package:truce/features/prices/presentation/prices_cubit.dart';
import 'package:truce/features/settings/presentation/settings_cubit.dart';
import 'package:truce/features/prices/presentation/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Using legacy anon key to ensure maximum compatibility with existing headers/filters
  await Supabase.initialize(
    url: 'https://mgqcolwglaavwazjwjir.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1ncWNvbHdnbGFhdndhemp3amlyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3NzM0MTUsImV4cCI6MjA5MjM0OTQxNX0.V_Y6Of9rIPqwHCanKgpYNRcFAOWClfFiSPgG5MUF1VM',
  );

  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthCubit>()),
        BlocProvider(create: (context) => di.sl<PricesCubit>()),
        BlocProvider(create: (context) => di.sl<SettingsCubit>()),
      ],
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return MaterialApp(
            title: 'Truce Egypt',
            theme: TruceTheme.lightTheme,
            darkTheme: TruceTheme.darkTheme,
            themeMode: settings.themeMode,
            locale: settings.locale,
            debugShowCheckedModeBanner: false,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}

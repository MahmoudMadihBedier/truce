import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:truce/core/utils/local_strings.dart';
import 'package:truce/core/utils/theme.dart';
import 'package:truce/features/auth/presentation/auth_cubit.dart';
import 'package:truce/features/auth/presentation/auth_dialog.dart';
import 'package:truce/features/settings/presentation/settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        final locale = settings.locale.languageCode;

        return Scaffold(
          appBar: AppBar(
            title: Text(LocalStrings.get('settings', locale)),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildSection(LocalStrings.get('theme', locale)),
              ListTile(
                leading: Icon(
                  settings.themeMode == ThemeMode.dark ? Icons.dark_mode : Icons.light_mode,
                  color: TruceTheme.accentGreen,
                ),
                title: Text(
                  settings.themeMode == ThemeMode.dark
                    ? LocalStrings.get('dark_mode', locale)
                    : LocalStrings.get('light_mode', locale)
                ),
                trailing: Switch(
                  value: settings.themeMode == ThemeMode.dark,
                  onChanged: (_) => context.read<SettingsCubit>().toggleTheme(),
                ),
              ),
              const SizedBox(height: 24),
              _buildSection(LocalStrings.get('language', locale)),
              ListTile(
                leading: const Icon(Icons.language, color: TruceTheme.accentGreen),
                title: Text(LocalStrings.get(locale == 'en' ? 'en_lang' : 'ar_lang', locale)),
                onTap: () {
                  final newLocale = locale == 'en' ? 'ar' : 'en';
                  context.read<SettingsCubit>().setLocale(newLocale);
                },
                trailing: const Icon(Icons.chevron_right),
              ),
              const SizedBox(height: 24),
              _buildSection(LocalStrings.get('account', locale)),
              BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  if (authState is AuthAuthenticated) {
                    return ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: Text(LocalStrings.get('logout', locale), style: const TextStyle(color: Colors.red)),
                      onTap: () => context.read<AuthCubit>().signOut(),
                    );
                  } else {
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Text(LocalStrings.get('guest_mode', locale), style: const TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => const AuthDialog(),
                          ),
                          child: Text(LocalStrings.get('login', locale)),
                        ),
                      ],
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}

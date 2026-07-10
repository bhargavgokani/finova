import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/settings_service.dart';
import '../../../../core/widgets/section_card.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';
import '../bloc/profile_state.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => locator<ProfileBloc>()..add(const LoadSettings()),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profileTitle)),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final bloc = context.read<ProfileBloc>();
          final colorScheme = Theme.of(context).colorScheme;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _ProfileHeader(),
              const SizedBox(height: 24),
              SectionCard(
                title: 'Edit Profile',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.person_outline),
                  title: Text(
                    state.name.isEmpty ? 'Add your details' : state.name,
                  ),
                  subtitle: state.email.isEmpty ? null : Text(state.email),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    await context.push(AppRoutes.editProfile);
                    if (context.mounted) bloc.add(const LoadSettings());
                  },
                ),
              ),
              const SizedBox(height: 24),
              SectionCard(
                title: 'Appearance',
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark Theme'),
                  value: state.themeMode == ThemeMode.dark,
                  onChanged: (_) => bloc.add(const ToggleTheme()),
                ),
              ),
              const SizedBox(height: 24),
              SectionCard(
                title: 'Preferences',
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.currency_exchange_outlined),
                      title: const Text('Currency'),
                      trailing: DropdownButton<AppCurrency>(
                        value: state.selectedCurrency,
                        underline: const SizedBox.shrink(),
                        items: AppCurrency.values
                            .map(
                              (currency) => DropdownMenuItem(
                                value: currency,
                                child: Text(currency.label),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null) bloc.add(ChangeCurrency(value));
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.notifications_outlined),
                      title: const Text('Notifications'),
                      value: state.notificationsEnabled,
                      onChanged: (_) => bloc.add(const ToggleNotifications()),
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.fingerprint),
                      title: const Text('Enable Biometric Login'),
                      subtitle: const Text('Placeholder - not yet functional'),
                      value: state.biometricEnabled,
                      onChanged: (_) => bloc.add(const ToggleBiometric()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionCard(
                title: 'Data',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.download_outlined),
                  title: const Text('Export Data'),
                  onTap: () => _showExportDataSheet(context, bloc),
                ),
              ),
              const SizedBox(height: 24),
              SectionCard(
                title: 'Information',
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline),
                      title: const Text('About'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(AppRoutes.about),
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.privacy_tip_outlined),
                      title: const Text('Privacy Policy'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(AppRoutes.privacy),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SectionCard(
                title: 'Account',
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.logout, color: colorScheme.error),
                  title: Text(
                    'Logout',
                    style: TextStyle(color: colorScheme.error),
                  ),
                  onTap: () {
                    bloc.add(const Logout());
                    context.go(AppRoutes.login);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showExportDataSheet(BuildContext context, ProfileBloc bloc) {
    final exportedJson = bloc.buildExportData();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        final textTheme = Theme.of(sheetContext).textTheme;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Exported Data',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(sheetContext).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    exportedJson,
                    style: textTheme.bodySmall,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            AppStrings.appName.substring(0, 1),
            style: textTheme.headlineMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          AppStrings.appName,
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          AppStrings.splashSubtitle,
          style: textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

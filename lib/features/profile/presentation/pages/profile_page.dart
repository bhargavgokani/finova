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
                title: 'Settings',
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      secondary: const Icon(Icons.dark_mode_outlined),
                      title: const Text('Dark Theme'),
                      value: state.themeMode == ThemeMode.dark,
                      onChanged: (_) => bloc.add(const ToggleTheme()),
                    ),
                    const Divider(height: 1),
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

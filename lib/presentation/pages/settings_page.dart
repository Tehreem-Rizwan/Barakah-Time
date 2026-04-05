import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../blocs/auth_bloc.dart';
import '../blocs/settings_bloc.dart';
import '../widgets/glass_box.dart';
import '../../core/localization/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundSlate,
      appBar: AppBar(
        title: Text(context.l10n.settings),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.all(24.w),
        children: [
          BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              if (state is Authenticated) {
                return _buildProfileTile(context, state.user);
              }
              return _buildProfileTile(context, null);
            },
          ),
          SizedBox(height: 32.h),
          _buildSection(context.l10n.app_settings),
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return Column(
                children: [
                  _buildSettingTile(
                    Icons.notifications_none,
                    context.l10n.notifications,
                    'Adhan, reminders & alerts',
                  ),
                  _buildSettingTile(
                    Icons.location_on_outlined,
                    context.l10n.location,
                    state.useAutoLocation ? 'Auto (GPS)' : state.manualLocation,
                    onTap: () => _showLocationDialog(context, state),
                  ),
                  _buildSettingTile(
                    Icons.language,
                    context.l10n.language,
                    _getLanguageName(state.languageCode, context),
                    onTap: () => _showLanguageDialog(context, state),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 32.h),
          _buildSection(context.l10n.preferences),
          BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, state) {
              return Column(
                children: [
                  _buildSettingTile(
                    Icons.mosque_outlined,
                    context.l10n.calculation_method,
                    state.calculationMethod,
                    onTap: () => _showCalculationMethodDialog(context),
                  ),
                  _buildSettingTile(
                    Icons.format_size,
                    context.l10n.quran_font_size,
                    '${state.quranFontSize.toInt()} px',
                    onTap: () => _showFontSizeDialog(context),
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 32.h),
          _buildSection(context.l10n.support),
          _buildSettingTile(Icons.star_outline, context.l10n.rate_us, 'Support our work', onTap: () => _handleRateUs(context)),
          _buildSettingTile(Icons.info_outline, context.l10n.about, 'Version 1.0.0', onTap: () => _showAboutDialog(context)),
        ],
      ),
    );
  }

  Widget _buildProfileTile(BuildContext context, dynamic user) {
    final name = user?.name ?? 'Barakah User';
    final email = user?.email ?? 'barakah.pro@email.com';

    return GlassBox(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundColor: AppColors.primaryEmerald.withOpacity(0.2),
            child: Icon(Icons.person, color: AppColors.secondaryGold, size: 30.sp),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(color: AppColors.textMain, fontSize: 18.sp, fontWeight: FontWeight.bold),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  email,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showEditProfileDialog(context, name, email),
            icon: Icon(Icons.edit_outlined, color: AppColors.textSecondary, size: 20.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, left: 4.w),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(color: AppColors.secondaryGold, fontSize: 12.sp, fontWeight: FontWeight.bold, letterSpacing: 1.5),
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title, String subtitle, {VoidCallback? onTap}) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: GlassBox(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.textMain, size: 22.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(color: AppColors.textMain, fontSize: 15.sp, fontWeight: FontWeight.w600)),
                    Text(subtitle, style: TextStyle(color: AppColors.textSecondary, fontSize: 12.sp)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20.sp),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, String currentName, String currentEmail) {
    final nameController = TextEditingController(text: currentName);
    final emailController = TextEditingController(text: currentEmail);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
        backgroundColor: AppColors.backgroundSlate,
        title: Text(context.l10n.edit_profile, style: TextStyle(color: AppColors.textMain)),
        content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: TextStyle(color: AppColors.textMain),
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary)),
                  ),
                ),
                SizedBox(height: 16.h),
                TextField(
                  controller: emailController,
                  style: TextStyle(color: AppColors.textMain),
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: AppColors.textSecondary),
                    enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary)),
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.cancel, style: TextStyle(color: AppColors.textSecondary))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald),
                onPressed: () {
                  context.read<AuthBloc>().add(UpdateProfileRequested(name: nameController.text, email: emailController.text));
                  Navigator.pop(context);
                },
                child: Text(context.l10n.save),
              ),
            ],
          ),
    );
  }

  void _showCalculationMethodDialog(BuildContext context) {
    final methods = ['Karachi', 'ISNA', 'MWL', 'Makkah', 'Dubai', 'Qatar'];
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundSlate,
            title: Text('Calculation Method', style: TextStyle(color: AppColors.textMain)),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: methods.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(methods[index], style: TextStyle(color: AppColors.textMain)),
                    onTap: () {
                      context.read<SettingsBloc>().add(UpdateCalculationMethod(methods[index]));
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ),
    );
  }

  void _showFontSizeDialog(BuildContext context) {
    final currentSize = context.read<SettingsBloc>().state.quranFontSize;
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundSlate,
            title: Text('Quran Font Size', style: TextStyle(color: AppColors.textMain)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatefulBuilder(
                  builder: (context, setState) {
                    return Column(
                      children: [
                        Text('${currentSize.toInt()}', style: TextStyle(color: AppColors.secondaryGold, fontSize: 24.sp)),
                        Slider(
                          value: context.read<SettingsBloc>().state.quranFontSize,
                          min: 16,
                          max: 48,
                          divisions: 8,
                          activeColor: AppColors.primaryEmerald,
                          onChanged: (value) {
                            context.read<SettingsBloc>().add(UpdateQuranFontSize(value));
                            setState(() {});
                          },
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: TextStyle(color: AppColors.textSecondary)))],
          ),
    );
  }

  void _showLocationDialog(BuildContext context, SettingsState state) {
    final manualController = TextEditingController(text: state.manualLocation);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundSlate,
            title: Text('Location Settings', style: TextStyle(color: AppColors.textMain)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SwitchListTile(
                  title: Text('Auto Location (GPS)', style: TextStyle(color: AppColors.textMain)),
                  value: state.useAutoLocation,
                  activeColor: AppColors.primaryEmerald,
                  onChanged: (value) {
                    context.read<SettingsBloc>().add(ToggleLocationMode(value));
                    Navigator.pop(context);
                  },
                ),
                if (!state.useAutoLocation) ...[
                  SizedBox(height: 16.h),
                  TextField(
                    controller: manualController,
                    style: TextStyle(color: AppColors.textMain),
                    decoration: InputDecoration(
                      labelText: 'Manual Location',
                      labelStyle: TextStyle(color: AppColors.textSecondary),
                      enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: AppColors.textSecondary)),
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
              if (!state.useAutoLocation)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryEmerald),
                  onPressed: () {
                    context.read<SettingsBloc>().add(UpdateManualLocation(manualController.text));
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
            ],
          ),
    );
  }

  void _handleRateUs(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundSlate,
            title: Text('Rate Us', style: TextStyle(color: AppColors.textMain)),
            content: Text(
              'If you enjoy Barakah Time, please take a moment to rate us on the Store! ✨',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: Text('Later', style: TextStyle(color: AppColors.textSecondary))),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondaryGold),
                onPressed: () {
                  // In a real app, open store link
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Redirecting to Store...'), backgroundColor: AppColors.primaryEmerald),
                  );
                },
                child: const Text('Rate Now'),
              ),
            ],
          ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundSlate,
            title: Text('About Barakah Time', style: TextStyle(color: AppColors.textMain)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 40.r,
                  backgroundColor: AppColors.primaryEmerald.withOpacity(0.1),
                  child: Icon(Icons.mosque_outlined, color: AppColors.secondaryGold, size: 40.sp),
                ),
                SizedBox(height: 16.h),
                Text('Version 1.0.0', style: TextStyle(color: AppColors.textMain, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Text(
                  'A premium Islamic productivity app designed to bring barakah to your time.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13.sp),
                ),
                SizedBox(height: 16.h),
                Text('Made with ❤️ for the Ummah', style: TextStyle(color: AppColors.secondaryGold, fontSize: 12.sp, fontStyle: FontStyle.italic)),
              ],
            ),
            actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close', style: TextStyle(color: AppColors.textSecondary)))],
          ),
    );
  }

  String _getLanguageName(String code, BuildContext context) {
    switch (code) {
      case 'en':
        return context.l10n.english;
      case 'ar':
        return context.l10n.arabic;
      case 'fa':
        return context.l10n.farsi;
      case 'ur':
        return context.l10n.urdu;
      case 'tr':
        return context.l10n.turkish;
      default:
        return context.l10n.english;
    }
  }

  void _showLanguageDialog(BuildContext context, SettingsState state) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppColors.backgroundSlate,
            title: Text(context.l10n.language, style: TextStyle(color: AppColors.textMain)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLanguageOption(context, 'en', context.l10n.english, state.languageCode),
                  _buildLanguageOption(context, 'ar', context.l10n.arabic, state.languageCode),
                  _buildLanguageOption(context, 'fa', context.l10n.farsi, state.languageCode),
                  _buildLanguageOption(context, 'ur', context.l10n.urdu, state.languageCode),
                  _buildLanguageOption(context, 'tr', context.l10n.turkish, state.languageCode),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String code, String name, String currentCode) {
    return ListTile(
      title: Text(name, style: TextStyle(color: AppColors.textMain)),
      trailing: code == currentCode ? const Icon(Icons.check, color: AppColors.primaryEmerald) : null,
      onTap: () {
        context.read<SettingsBloc>().add(UpdateLanguage(code));
        Navigator.pop(context);
      },
    );
  }
}

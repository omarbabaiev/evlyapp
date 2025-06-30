import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';
import '../core/localization/translations.dart';
import '../services/auth_service.dart';
import 'package:get_storage/get_storage.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ThemeMode _themeMode = ThemeMode.light;
  String _selectedLanguage = 'az';
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _themeMode = Get.theme.brightness == Brightness.dark
        ? ThemeMode.dark
        : ThemeMode.light;
    _selectedLanguage = Get.locale?.languageCode ?? 'az';
  }

  void _changeTheme(ThemeMode? mode) {
    if (mode == null) return;
    setState(() {
      _themeMode = mode;
    });
    box.write('theme_mode', mode.toString());
    Get.changeThemeMode(mode);
  }

  void _changeLanguage(String? langCode) {
    if (langCode == null) return;
    setState(() {
      _selectedLanguage = langCode;
    });
    box.write('locale', langCode);
    if (langCode == 'az') {
      Get.updateLocale(const Locale('az', 'AZ'));
    } else {
      Get.updateLocale(const Locale('en', 'US'));
    }
  }

  void _showTerms() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('İstifadəçi Şərtləri',
            style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Text(
            'Burada istifadəçi şərtləri yerləşəcək...\n\n(Əlavə mətn əlavə edin)',
            style: GoogleFonts.poppins(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Bağla', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _logout() async {
    await Get.find<AuthService>().signOut();
    Get.offAllNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          'Tənzimləmələr',
          style: GoogleFonts.poppins(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
        ),
      ),
      body: ListView(
        children: [
          // Theme Mode
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Tema',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  value: ThemeMode.light,
                  groupValue: _themeMode,
                  onChanged: _changeTheme,
                  title: Text('Açıq', style: GoogleFonts.poppins()),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.dark,
                  groupValue: _themeMode,
                  onChanged: _changeTheme,
                  title: Text('Qaranlıq', style: GoogleFonts.poppins()),
                ),
                RadioListTile<ThemeMode>(
                  value: ThemeMode.system,
                  groupValue: _themeMode,
                  onChanged: _changeTheme,
                  title: Text('Sistem', style: GoogleFonts.poppins()),
                ),
              ],
            ),
          ),
          // Language
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Dil',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                RadioListTile<String>(
                  value: 'az',
                  groupValue: _selectedLanguage,
                  onChanged: _changeLanguage,
                  title: Text('Azərbaycan dili', style: GoogleFonts.poppins()),
                ),
                RadioListTile<String>(
                  value: 'en',
                  groupValue: _selectedLanguage,
                  onChanged: _changeLanguage,
                  title: Text('English', style: GoogleFonts.poppins()),
                ),
              ],
            ),
          ),
          // Terms
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Digər',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: AppColors.textPrimary)),
          ),
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.description, color: AppColors.primary),
                  title:
                      Text('İstifadəçi Şərtləri', style: GoogleFonts.poppins()),
                  onTap: _showTerms,
                ),
                ListTile(
                  leading: Icon(Icons.logout, color: AppColors.error),
                  title: Text('Çıxış',
                      style: GoogleFonts.poppins(color: AppColors.error)),
                  onTap: _logout,
                ),
              ],
            ),
          ),
          // App version
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'Versiya 1.0.0',
                style: GoogleFonts.poppins(
                    color: AppColors.textMuted, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

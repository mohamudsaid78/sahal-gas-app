import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/app_localizations.dart';
import '../../services/app_settings.dart';
import '../../widgets/app_page.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _notifications = true;
  bool _offers = true;
  bool _analytics = true;
  bool _location = true;
  String _language = 'English';
  String _appearance = 'Light';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final n = await AppSettings.notificationsEnabled();
    final o = await AppSettings.offersEnabled();
    final analytics = await AppSettings.analyticsEnabled();
    final location = await AppSettings.locationEnabled();
    final language = await AppSettings.language();
    final appearance = await AppSettings.appearance();
    if (mounted) {
      setState(() {
        _notifications = n;
        _offers = o;
        _analytics = analytics;
        _location = location;
        _language = language;
        _appearance = appearance;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AppPage(
      title: l10n.text('settings'),
      child: Container(
        color: const Color(0xfff7f3f1),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
          children: [
            _section(
              title: l10n.text('general'),
              children: [
                _choiceTile(
                  icon: Icons.language_outlined,
                  title: l10n.text('language'),
                  value: _language,
                  onTap: () => _chooseLanguage(context),
                ),
                _choiceTile(
                  icon: Icons.palette_outlined,
                  title: l10n.text('appearance'),
                  value: _appearance,
                  onTap: () => _chooseAppearance(context),
                ),
              ],
            ),
            _section(
              title: l10n.text('notifications'),
              children: [
                _switchTile(
                  icon: Icons.notifications_outlined,
                  title: l10n.text('pushNotifications'),
                  subtitle: 'Receive order and delivery updates',
                  value: _notifications,
                  onChanged: (v) async {
                    setState(() => _notifications = v);
                    await AppSettings.setNotificationsEnabled(v);
                  },
                ),
                _switchTile(
                  icon: Icons.local_offer_outlined,
                  title: l10n.text('offers'),
                  subtitle: 'Receive special offers from Sahal Gas',
                  value: _offers,
                  onChanged: (v) async {
                    setState(() => _offers = v);
                    await AppSettings.setOffersEnabled(v);
                  },
                ),
              ],
            ),
            _section(
              title: l10n.text('privacy'),
              children: [
                _switchTile(
                  icon: Icons.location_on_outlined,
                  title: l10n.text('location'),
                  subtitle: 'Use location to improve delivery service',
                  value: _location,
                  onChanged: (v) async {
                    setState(() => _location = v);
                    await AppSettings.setLocationEnabled(v);
                  },
                ),
                _switchTile(
                  icon: Icons.analytics_outlined,
                  title: l10n.text('analytics'),
                  subtitle: 'Help improve the Sahal Gas app',
                  value: _analytics,
                  onChanged: (v) async {
                    setState(() => _analytics = v);
                    await AppSettings.setAnalyticsEnabled(v);
                  },
                ),
              ],
            ),
            _section(
              title: l10n.text('account'),
              children: [
                _infoTile(
                  icon: Icons.lock_outline,
                  title: l10n.text('privacyPolicy'),
                  onTap: () => _showInfo(context, 'Privacy policy', 'Your account and payment details are handled securely. Card CVV and mobile money PIN are never saved.'),
                ),
                _infoTile(
                  icon: Icons.info_outline,
                  title: l10n.text('about'),
                  onTap: () => _showInfo(context, 'About Sahal Gas', 'Sahal Gas delivery app'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _section({required String title, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title,
              style: const TextStyle(
                color: Color(0xff252525),
                fontSize: 15,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xffeadfdb)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Material(
                color: Colors.white,
                child: Column(children: children),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _choiceTile({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      leading: Icon(icon, color: const Color(0xff635852)),
      title: Text(title),
      subtitle: Text(value, style: const TextStyle(color: Color(0xff756963))),
      trailing: const Icon(Icons.chevron_right, color: Color(0xffed1c24)),
      onTap: onTap,
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile.adaptive(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      secondary: Icon(icon, color: const Color(0xff635852)),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(color: Color(0xff756963))),
      value: value,
      activeColor: const Color(0xffed1c24),
      onChanged: onChanged,
    );
  }

  Widget _infoTile({required IconData icon, required String title, required VoidCallback onTap}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
      leading: Icon(icon, color: const Color(0xff635852)),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Color(0xffed1c24)),
      onTap: onTap,
    );
  }

  Future<void> _chooseLanguage(BuildContext context) async {
    final value = await _chooseValue(context, 'Language', [
      'English',
      'Somali',
      'Arabic',
      'Chinese',
      'French',
      'Spanish',
      'Turkish',
      'Swahili',
      'Hindi',
      'Portuguese',
    ], _language);
    if (value != null) {
      setState(() => _language = value);
      await AppScope.of(context, listen: false).setLanguage(value);
    }
  }

  Future<void> _chooseAppearance(BuildContext context) async {
    final value = await _chooseValue(context, 'Appearance', ['Light', 'System default', 'Dark'], _appearance);
    if (value != null) {
      setState(() => _appearance = value);
      await AppScope.of(context, listen: false).setAppearance(value);
    }
  }

  Future<String?> _chooseValue(BuildContext context, String title, List<String> values, String selected) {
    return showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: values.map((value) => RadioListTile<String>(
          value: value,
          groupValue: selected,
          title: Text(value),
          onChanged: (value) => Navigator.of(context).pop(value),
        )).toList(),
      ),
    );
  }

  void _showInfo(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../auth/auth_screen.dart';
import 'dart:typed_data';

import '../../app/app_scope.dart';
import '../../app/app_theme.dart';
import '../../widgets/app_page.dart';
import '../../services/image_service.dart';
import 'edit_address_screen.dart';
import 'payment_methods_screen.dart';
import 'offers_screen.dart';
import 'live_chat_screen.dart';
import 'change_password_screen.dart';
import 'app_settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final user = AppScope.of(context, listen: false).currentUser;
    if (user == null) return;
    final bytes = await ImageService.loadSavedImage(userId: user.id);
    if (bytes != null && mounted) setState(() => _avatarBytes = bytes);
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final user = controller.currentUser;
    if (user == null) {
      // If the user was signed out while this screen is visible, avoid
      // accessing properties on a null user which causes a crash. The
      // app's root gate will react to the signed-out state and show the
      // auth screen, so just render nothing here.
      return const SizedBox.shrink();
    }

    Widget leadingIcon(IconData icon, Color bg) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: bg.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: bg),
      );
    }

    return AppPage(
      title: 'My Profile',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          // Header with red gradient and avatar + camera button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: const LinearGradient(
                colors: [Color(0xffc62828), Color(0xffef5350)],
              ),
            ),
            child: Row(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.white,
                      backgroundImage: _avatarBytes != null
                          ? MemoryImage(_avatarBytes!)
                          : null,
                      child: _avatarBytes == null
                          ? Icon(
                              Icons.person,
                              color: Color(0xffc62828),
                              size: 40,
                            )
                          : null,
                    ),
                    Positioned(
                      right: -6,
                      bottom: -6,
                      child: GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (_) => SafeArea(
                              child: Wrap(
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.photo_library),
                                    title: const Text('Choose Image'),
                                    onTap: () async {
                                      Navigator.of(context).pop();
                                      final bytes =
                                          await ImageService.pickAndSaveImage(
                                            userId: user.id,
                                          );
                                      if (bytes != null && mounted)
                                        setState(() => _avatarBytes = bytes);
                                    },
                                  ),
                                  if (_avatarBytes != null)
                                    ListTile(
                                      leading: const Icon(Icons.delete),
                                      title: const Text('Remove Photo'),
                                      onTap: () async {
                                        Navigator.of(context).pop();
                                        await ImageService.removeSavedImage(
                                          userId: user.id,
                                        );
                                        if (mounted)
                                          setState(() => _avatarBytes = null);
                                      },
                                    ),
                                  ListTile(
                                    leading: const Icon(Icons.close),
                                    title: const Text('Cancel'),
                                    onTap: () => Navigator.of(context).pop(),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Color(0xffc62828),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              user.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.phone,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      // Admin badge pill
                      if (user.role.label.toLowerCase() == 'admin')
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Admin',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Section A: Account Details
          const Text(
            'Account Details',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                ListTile(
                  leading: leadingIcon(
                    Icons.location_on_outlined,
                    Color(0xffc62828),
                  ),
                  title: const Text('Address'),
                  subtitle: Text(
                    user.address.isEmpty ? 'Not set' : user.address,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const EditAddressScreen(),
                        ),
                      );
                      if (result == true && context.mounted) setState(() {});
                    },
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: leadingIcon(
                    Icons.account_balance_wallet_outlined,
                    AppTheme.orange,
                  ),
                  title: const Text('Payment Methods'),
                  subtitle: const Text('EVC Plus, Card, Cash'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PaymentMethodsScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Section B: App Settings & Offers
          const Text(
            'App Settings & Offers',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                ListTile(
                  leading: leadingIcon(
                    Icons.settings_outlined,
                    Colors.blueGrey,
                  ),
                  title: const Text('App Settings'),
                  subtitle: const Text(
                    'Language, appearance, notifications and privacy',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const AppSettingsScreen(),
                    ),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: leadingIcon(
                    Icons.local_offer_outlined,
                    AppTheme.orange,
                  ),
                  title: const Text('Offers & Promotions'),
                  subtitle: const Text('Delivery deals and cylinder refills'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const OffersScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: leadingIcon(Icons.notifications_none, AppTheme.blue),
                  title: const Text('Notifications'),
                  subtitle: const Text('Order and delivery updates'),
                  trailing: Switch(
                    value: _notificationsEnabled,
                    onChanged: (v) => setState(() => _notificationsEnabled = v),
                  ),
                  onTap: () => setState(
                    () => _notificationsEnabled = !_notificationsEnabled,
                  ),
                ),
              ],
            ),
          ),

          // Section C: Support & Security
          const Text(
            'Support & Security',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Column(
              children: [
                ListTile(
                  leading: leadingIcon(Icons.chat_bubble_outline, Colors.green),
                  title: const Text('Live Chat'),
                  subtitle: const Text('Chat with the support team'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LiveChatScreen()),
                  ),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: leadingIcon(Icons.phone_outlined, AppTheme.orange),
                  title: const Text('Call Us'),
                  subtitle: const Text('+252 61 234 5678'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => launchUrl(Uri.parse('tel:+252612345678')),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: leadingIcon(Icons.lock_outline, Colors.grey),
                  title: const Text('Change Password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: controller.busy
                ? null
                : () async {
                    // Ensure we wait for sign out to complete, then clear
                    // navigation and show the auth screen.
                    await controller.signOut();
                    if (!mounted) return;
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const AuthScreen()),
                      (route) => false,
                    );
                  },
            icon: const Icon(Icons.logout),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

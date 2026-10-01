import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/app_scope.dart';
import '../../core/enums.dart';
import '../../models/gas_user.dart';
import '../../widgets/api_state.dart';
import '../../widgets/app_page.dart';

class AdminDriversScreen extends StatefulWidget {
  const AdminDriversScreen({super.key});

  @override
  State<AdminDriversScreen> createState() => _AdminDriversScreenState();
}

class _AdminDriversScreenState extends State<AdminDriversScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);

    return AppPage(
      title: 'Drivers',
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xffdfe3e8)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) => setState(() => _search = value),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    border: InputBorder.none,
                    hintText: 'Search drivers...',
                    hintStyle: TextStyle(fontSize: 18, color: Color(0xff6f6f6f)),
                    prefixIcon: Icon(Icons.search_rounded, size: 24, color: Color(0xff535353)),
                  ),
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            Expanded(
              child: ApiState<List<GasUser>>(
                future: controller.userRepository.fetchDrivers(),
                builder: (context, drivers) {
                  final filtered = drivers.where((driver) {
                    final query = _search.trim().toLowerCase();
                    if (query.isEmpty) return true;
                    return driver.name.toLowerCase().contains(query) ||
                        driver.phone.toLowerCase().contains(query) ||
                        driver.address.toLowerCase().contains(query);
                  }).toList();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
                    children: [
                      Text(
                        'Total Drivers (${filtered.length})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xff1d1d1d),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...filtered.map((driver) => _DriverCard(
                        driver: driver,
                        onUpdated: () => setState(() {}),
                      )),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  const _DriverCard({
    required this.driver,
    this.onUpdated,
  });

  final GasUser driver;
  final VoidCallback? onUpdated;

  @override
  Widget build(BuildContext context) {
    final active = driver.active;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xffe7e9ee)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: const Color(0xffdfeaf5),
            child: Text(
              _initials(driver.name),
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: Color(0xff1d1d1d),
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        driver.name,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff1d1d1d),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xffdff6e9),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_rounded, size: 16, color: const Color(0xff1b9c57)),
                          const SizedBox(width: 6),
                          const Text(
                            'Verified Driver',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xff1b9c57),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    _StatusBadge(active: active),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.phone_android_rounded, size: 20, color: Color(0xff3d4a5a)),
                    const SizedBox(width: 8),
                    Text(
                      driver.phone,
                      style: const TextStyle(fontSize: 18, color: Color(0xff2f2f2f)),
                    ),
                    const SizedBox(width: 18),
                    const Icon(Icons.location_on_outlined, size: 20, color: Color(0xff3d4a5a)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        driver.address.isEmpty ? 'Location not set' : driver.address,
                        style: const TextStyle(fontSize: 17, color: Color(0xff2f2f2f)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.electric_scooter_rounded, size: 22, color: Color(0xff3d4a5a)),
                    const SizedBox(width: 8),
                    Text(
                      'Vehicle: Tricycle (ID: ${_shortId(driver.id)})',
                      style: const TextStyle(fontSize: 18, color: Color(0xff2f2f2f)),
                    ),
                    const Spacer(),
                    Row(
                      children: List.generate(5, (index) {
                        final filled = index < 4;
                        return Icon(
                          filled ? Icons.star_rounded : Icons.star_border_rounded,
                          color: filled ? const Color(0xfff5b400) : const Color(0xffd4d4d4),
                          size: 18,
                        );
                      }),
                    ),
                    const SizedBox(width: 8),
                    const Text('4.8', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xff2d2d2d))),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _ActionButton(
                        label: 'Call',
                        icon: Icons.call_rounded,
                        color: const Color(0xffcfe9ff),
                        onPressed: () => _launchCall(driver.phone),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: 'Message',
                        icon: Icons.message_rounded,
                        color: const Color(0xffd9ebff),
                        onPressed: () => _showMessageDialog(context, driver),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _ActionButton(
                        label: 'Track',
                        icon: Icons.location_on_rounded,
                        color: const Color(0xffd9ebff),
                        onPressed: () => _launchTrack(driver.address.isEmpty ? 'Current Location' : driver.address),
                      ),
                    ),
                    const SizedBox(width: 10),
                    _ManageButton(
                      onPressed: () => _showDriverManagerDialog(context, driver),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchCall(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone.trim());
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch phone');
    }
  }

  Future<void> _launchTrack(String destination) async {
    final query = Uri.encodeComponent(destination);
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=Current+Location&destination=$query');
    if (!await launchUrl(uri)) {
      debugPrint('Could not launch map');
    }
  }

  Future<void> _showMessageDialog(BuildContext context, GasUser driver) async {
    final messageController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Send message'),
          content: SizedBox(
            width: 420,
            child: TextField(
              controller: messageController,
              minLines: 4,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: 'Write a message for this driver...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = messageController.text.trim();
                Navigator.pop(dialogContext, text);
              },
              child: const Text('Send'),
            ),
          ],
        );
      },
    );

    if (result == null || result.trim().isEmpty) return;

    final uri = Uri(
      scheme: 'sms',
      path: driver.phone,
      queryParameters: {'body': result.trim()},
    );
    if (!await launchUrl(uri)) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to send SMS to ${driver.name}.')),
        );
      }
    }
  }

  Future<void> _showDriverManagerDialog(BuildContext context, GasUser driver) async {
    final controller = AppScope.of(context, listen: false);
    final nameController = TextEditingController(text: driver.name);
    final phoneController = TextEditingController(text: driver.phone);
    final addressController = TextEditingController(text: driver.address);
    var selectedRole = driver.role;
    var active = driver.active;

    final result = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Manage ${driver.name}'),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 420,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Full name'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: 'Phone'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: addressController,
                        maxLines: 2,
                        decoration: const InputDecoration(labelText: 'Address'),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<UserRole>(
                        value: selectedRole,
                        decoration: const InputDecoration(labelText: 'Role'),
                        items: UserRole.values
                            .map((role) => DropdownMenuItem(value: role, child: Text(role.label)))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => selectedRole = value);
                        },
                      ),
                      const SizedBox(height: 14),
                      SwitchListTile.adaptive(
                        value: active,
                        title: const Text('Active / Available'),
                        onChanged: (value) => setState(() => active = value),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final updatedName = nameController.text.trim();
                    final updatedPhone = phoneController.text.trim();
                    final updatedAddress = addressController.text.trim();

                    await controller.userRepository.updateProfile(
                      userId: driver.id,
                      name: updatedName,
                      phone: updatedPhone,
                      address: updatedAddress,
                    );
                    await controller.userRepository.updateRole(driver.id, selectedRole);
                    await controller.userRepository.updateActive(driver.id, active);

                    if (context.mounted) {
                      Navigator.pop(dialogContext, true);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${driver.name} updated successfully.')),
      );
      onUpdated?.call();
    }
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    final initials = parts.take(2).map((part) => part.isNotEmpty ? part[0].toUpperCase() : '').join();
    return initials.isEmpty ? 'D' : initials;
  }

  String _shortId(String id) {
    if (id.isEmpty) return 'N/A';
    return id.substring(0, id.length < 4 ? id.length : 4);
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      style: FilledButton.styleFrom(
        backgroundColor: color,
        foregroundColor: const Color(0xff0f2f4f),
        minimumSize: const Size.fromHeight(46),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _ManageButton extends StatelessWidget {
  const _ManageButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 58,
      height: 46,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xffdfeffd),
          foregroundColor: const Color(0xff0f2f4f),
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Icon(Icons.manage_accounts_rounded, size: 22),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.active});

  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? const Color(0xffdff6e9) : const Color(0xfffdf0db);
    final textColor = active ? const Color(0xff1b9c57) : const Color(0xffb77700);
    final label = active ? 'Online' : 'On Delivery';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: textColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

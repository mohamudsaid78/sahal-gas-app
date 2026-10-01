import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/app_scope.dart';
import '../../app/app_theme.dart';
import '../../core/enums.dart';
import '../../models/gas_user.dart';
import '../../widgets/api_state.dart';
import '../../widgets/app_page.dart';
import '../../widgets/empty_state.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  String _search = '';
  UserRole? _role;

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return AppPage(
      title: 'Manage Users',
      actions: [
        IconButton(
          tooltip: 'Create user',
          onPressed: () => _showUserCreator(context),
          icon: const Icon(Icons.person_add_alt_1_outlined),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 24),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.7)),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _search = value),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search for name, role, etc.',
                  prefixIcon: Icon(Icons.search, color: Colors.black54, size: 26),
                  hintStyle: TextStyle(fontSize: 20, color: Color(0xff6d6d6d)),
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ChoiceChip(
                  label: const Text('All', style: TextStyle(fontSize: 18)),
                  selected: _role == null,
                  onSelected: (_) => setState(() => _role = null),
                  selectedColor: const Color(0xfff4d8d3),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: Color(0xffe0d7d5)),
                  ),
                  labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                ),
                for (final role in UserRole.values)
                  ChoiceChip(
                    label: Text(role.label, style: const TextStyle(fontSize: 18)),
                    selected: _role == role,
                    onSelected: (_) => setState(() => _role = role),
                    selectedColor: const Color(0xfff4d8d3),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xffe0d7d5)),
                    ),
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            ApiState<List<GasUser>>(
              future: controller.userRepository.fetchUsers(role: _role, search: _search),
              isEmpty: (users) => users.isEmpty,
              empty: const EmptyState(
                icon: Icons.group_outlined,
                title: 'No users found',
                message: 'Users who sign up will appear here.',
              ),
              builder: (context, users) {
                return Column(
                  children: users.map((user) {
                    final roleColor = _roleColor(user.role);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xffe7e1df)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: roleColor.withValues(alpha: 0.18),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(_roleIcon(user.role), color: roleColor, size: 28),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xff1d1d1d),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(Icons.phone, size: 16, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            user.phone,
                                            style: const TextStyle(color: Colors.black87, fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            user.address.isNotEmpty ? user.address : 'Somalia',
                                            style: const TextStyle(color: Colors.black87, fontSize: 15),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 120,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xfff0f0f0),
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(color: const Color(0xffe8e8e8)),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<UserRole>(
                                        value: user.role,
                                        isExpanded: true,
                                        icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                                        style: const TextStyle(
                                          color: Color(0xff1b1b1b),
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        items: UserRole.values.map((role) {
                                          return DropdownMenuItem(
                                            value: role,
                                            child: Text(role.label),
                                          );
                                        }).toList(),
                                        onChanged: (role) async {
                                          if (role == null) return;
                                          await controller.userRepository.updateRole(user.id, role);
                                          if (context.mounted) setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Container(
                                    width: 120,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: user.active ? const Color(0xffeaf6ec) : const Color(0xfffbeee8),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: DropdownButtonHideUnderline(
                                      child: DropdownButton<bool>(
                                        value: user.active,
                                        isDense: true,
                                        icon: const Icon(Icons.keyboard_arrow_down, size: 18),
                                        style: TextStyle(
                                          color: user.active ? Colors.green.shade800 : Colors.orange.shade800,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                        ),
                                        items: const [
                                          DropdownMenuItem(value: true, child: Text('Active')),
                                          DropdownMenuItem(value: false, child: Text('Inactive')),
                                        ],
                                        onChanged: (value) async {
                                          if (value == null) return;
                                          await controller.userRepository.updateActive(user.id, value);
                                          if (context.mounted) setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              _iconActionButton(
                                icon: Icons.edit_outlined,
                                label: 'Edit',
                                bg: const Color(0xffedf3ff),
                                foreground: const Color(0xff2d6cdf),
                                onTap: () => _showUserEditor(context, user),
                              ),
                              const SizedBox(width: 10),
                              _iconActionButton(
                                icon: Icons.delete_outline,
                                label: 'Delete',
                                bg: const Color(0xfffdeceb),
                                foreground: const Color(0xffd84a3e),
                                onTap: () async {
                                  await controller.userRepository.deleteUser(user.id);
                                  if (context.mounted) setState(() {});
                                },
                              ),
                              const SizedBox(width: 10),
                              PopupMenuButton<String>(
                                tooltip: 'Options',
                                offset: const Offset(0, 42),
                                onSelected: (value) async {
                                  if (value == 'edit') {
                                    _showUserEditor(context, user);
                                    return;
                                  }
                                  if (value == 'delete') {
                                    await controller.userRepository.deleteUser(user.id);
                                    if (context.mounted) setState(() {});
                                    return;
                                  }
                                  if (value == 'details') {
                                    showDialog<void>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text(user.name),
                                        content: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Role: ${user.role.label}'),
                                            const SizedBox(height: 8),
                                            Text('Phone: ${user.phone}'),
                                            const SizedBox(height: 8),
                                            Text('Address: ${user.address.isEmpty ? 'Not provided' : user.address}'),
                                            const SizedBox(height: 8),
                                            Text('Status: ${user.active ? 'Active' : 'Inactive'}'),
                                          ],
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit_outlined, size: 18),
                                        SizedBox(width: 10),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'details',
                                    child: Row(
                                      children: [
                                        Icon(Icons.visibility_outlined, size: 18),
                                        SizedBox(width: 10),
                                        Text('View details'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete_outline, size: 18),
                                        SizedBox(width: 10),
                                        Text('Delete'),
                                      ],
                                    ),
                                  ),
                                ],
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: const Color(0xfff3f3f3),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.more_horiz, size: 18, color: Color(0xff4a4a4a)),
                                      SizedBox(width: 6),
                                      Text(
                                        'Options',
                                        style: TextStyle(
                                          color: Color(0xff4a4a4a),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _roleIcon(UserRole role) {
    return switch (role) {
      UserRole.admin => Icons.admin_panel_settings_outlined,
      UserRole.driver => Icons.delivery_dining_outlined,
      UserRole.customer => Icons.person_outline,
    };
  }

  Color _roleColor(UserRole role) {
    return switch (role) {
      UserRole.admin => AppTheme.orange,
      UserRole.driver => AppTheme.blue,
      UserRole.customer => AppTheme.green,
    };
  }

  void _showUserEditor(BuildContext context, GasUser user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _UserEditorSheet(
        user: user,
        onSaved: () => setState(() {}),
      ),
    );
  }

  void _showUserCreator(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => _UserCreatorSheet(onSaved: () => setState(() {})),
    );
  }

  Widget _iconActionButton({
    required IconData icon,
    required String label,
    required Color bg,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: foreground),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserEditorSheet extends StatefulWidget {
  const _UserEditorSheet({required this.user, required this.onSaved});

  final GasUser user;
  final VoidCallback onSaved;

  @override
  State<_UserEditorSheet> createState() => _UserEditorSheetState();
}

class _UserCreatorSheet extends StatefulWidget {
  const _UserCreatorSheet({required this.onSaved});

  final VoidCallback onSaved;

  @override
  State<_UserCreatorSheet> createState() => _UserCreatorSheetState();
}

class _UserCreatorSheetState extends State<_UserCreatorSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  UserRole _role = UserRole.driver;
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.viewInsetsOf(context).bottom + 18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text('Create User', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: _required,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Temporary password'),
                  validator: (value) => (value ?? '').length < 4 ? 'Use at least 4 characters.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  value: _role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: UserRole.values
                      .map((role) => DropdownMenuItem(value: role, child: Text(role.label)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _role = value);
                  },
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: _saving ? null : () => _save(controller),
                  icon: _saving
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.person_add_alt_1_outlined),
                  label: const Text('Create user'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(AppController controller) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      await controller.userRepository.createUser(
        name: _nameController.text,
        username: _usernameController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        role: _role,
        address: _addressController.text,
      );
      if (!mounted) return;
      widget.onSaved();
      Navigator.of(context).pop();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))));
        setState(() => _saving = false);
      }
    }
  }

  String? _required(String? value) {
    return (value ?? '').trim().isEmpty ? 'Required' : null;
  }
}

class _UserEditorSheetState extends State<_UserEditorSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late UserRole _role;
  late bool _active;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _addressController = TextEditingController(text: user.address);
    _role = user.role;
    _active = user.active;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.viewInsetsOf(context).bottom + 18),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Edit User',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                  validator: (value) => (value == null || value.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<UserRole>(
                  value: _role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: UserRole.values
                      .map((role) => DropdownMenuItem(value: role, child: Text(role.label)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) setState(() => _role = value);
                  },
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: _active,
                  title: const Text('Active user'),
                  onChanged: (value) => setState(() => _active = value),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    await controller.userRepository.updateProfile(
                      userId: widget.user.id,
                      name: _nameController.text.trim(),
                      phone: _phoneController.text.trim(),
                      address: _addressController.text.trim(),
                    );
                    if (_role != widget.user.role) {
                      await controller.userRepository.updateRole(widget.user.id, _role);
                    }
                    if (_active != widget.user.active) {
                      await controller.userRepository.updateActive(widget.user.id, _active);
                    }
                    if (context.mounted) {
                      widget.onSaved();
                      Navigator.of(context).pop();
                    }
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Save changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../app/app_scope.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _old = TextEditingController();
  final _new = TextEditingController();
  final _confirm = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _old.dispose();
    _new.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    final currentPassword = _old.text;
    final newPassword = _new.text;
    final confirmation = _confirm.text;
    if (currentPassword.isEmpty || newPassword.isEmpty) {
      _showMessage('Please fill in all password fields.');
      return;
    }
    if (newPassword.length < 6) {
      _showMessage('New password must be at least 6 characters.');
      return;
    }
    if (newPassword != confirmation) {
      _showMessage('New passwords do not match.');
      return;
    }
    if (currentPassword == newPassword) {
      _showMessage('New password must be different from the current password.');
      return;
    }

    final controller = AppScope.of(context, listen: false);
    final user = controller.currentUser;
    if (user == null) {
      _showMessage('Your session has expired. Please sign in again.');
      return;
    }

    setState(() => _saving = true);
    try {
      await controller.authRepository.changePassword(
        userId: user.id,
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password changed successfully.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      _showMessage(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Password')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: _old, decoration: const InputDecoration(labelText: 'Current password'), obscureText: true),
            const SizedBox(height: 8),
            TextField(controller: _new, decoration: const InputDecoration(labelText: 'New password'), obscureText: true),
            const SizedBox(height: 8),
            TextField(controller: _confirm, decoration: const InputDecoration(labelText: 'Confirm new password'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saving ? null : _changePassword,
              child: _saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Change Password'),
            )
          ],
        ),
      ),
    );
  }
}

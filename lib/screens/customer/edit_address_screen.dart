import 'package:flutter/material.dart';

import '../../app/app_scope.dart';

class EditAddressScreen extends StatefulWidget {
  const EditAddressScreen({super.key});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  final _controller = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = AppScope.of(context, listen: false).currentUser;
    _controller.text = user?.address ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final user = controller.currentUser!;
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Address')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Delivery address'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saving
                        ? null
                        : () async {
                            setState(() => _saving = true);
                            await controller.userRepository.updateProfile(
                              userId: user.id,
                              name: user.name,
                              phone: user.phone,
                              address: _controller.text.trim(),
                            );
                            final refreshed = await controller.authRepository.fetchUserById(user.id);
                            if (refreshed != null) {
                              controller.setCurrentUser(refreshed);
                            }
                            if (mounted) Navigator.of(context).pop(true);
                          },
                    child: const Text('Save'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

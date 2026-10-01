import 'package:flutter/material.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  final _methods = <String>['EVC Plus', 'Card', 'Cash'];
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: _methods.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) => ListTile(
                  title: Text(_methods[i]),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => setState(() => _methods.removeAt(i)),
                  ),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Add method')),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    final t = _controller.text.trim();
                    if (t.isEmpty) return;
                    setState(() {
                      _methods.add(t);
                      _controller.clear();
                    });
                  },
                  child: const Text('Add'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

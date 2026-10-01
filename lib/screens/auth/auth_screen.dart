import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+252 ');
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  bool _creatingAccount = false;

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
    final size = MediaQuery.sizeOf(context);
    final wide = size.width >= 900;
    final formPanel = Card(
      child: Padding(
        padding: EdgeInsets.all(wide ? 28 : 18),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _creatingAccount ? 'Create your account' : 'Welcome back',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _creatingAccount
                    ? 'Create a customer account to order gas for delivery.'
                  : 'Sign in with your username and password to continue.',
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 22),
              if (_creatingAccount) ...[
                TextFormField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: _usernameValidator,
              ),
              const SizedBox(height: 12),
              if (_creatingAccount) ...[
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Phone number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: _required,
                ),
                const SizedBox(height: 12),
              ],
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                ),
                validator: (value) {
                  if ((value ?? '').length < 4) {
                    return 'Use at least 4 characters.';
                  }
                  return null;
                },
              ),
              if (_creatingAccount) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _addressController,
                  minLines: 1,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Delivery address',
                    prefixIcon: Icon(Icons.location_on_outlined),
                  ),
                  validator: _required,
                ),
              ],
              if (controller.actionMessage != null) ...[
                const SizedBox(height: 14),
                _MessageBanner(message: controller.actionMessage!),
              ],
              if (controller.startupMessage != null) ...[
                const SizedBox(height: 14),
                _MessageBanner(message: controller.startupMessage!),
              ],
              const SizedBox(height: 22),
              FilledButton.icon(
                onPressed: controller.busy ? null : _submit,
                icon: controller.busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(_creatingAccount ? Icons.person_add_alt : Icons.login),
                label: Text(_creatingAccount ? 'Create account' : 'Sign in'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: controller.busy
                    ? null
                    : () {
                        setState(() {
                          _creatingAccount = !_creatingAccount;
                        });
                      },
                child: Text(
                  _creatingAccount
                      ? 'I already have an account'
                      : 'Create a new account',
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: wide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(flex: 5, child: _BrandPanel()),
                        const SizedBox(width: 18),
                        Expanded(flex: 4, child: formPanel),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const _BrandPanel(),
                        const SizedBox(height: 18),
                        formPanel,
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final controller = AppScope.of(context, listen: false);
    if (_creatingAccount) {
      await controller.signUp(
        name: _nameController.text,
        username: _usernameController.text,
        phone: _phoneController.text,
        password: _passwordController.text,
        address: _addressController.text,
      );
    } else {
      await controller.signIn(
        username: _usernameController.text,
        password: _passwordController.text,
      );
    }
  }

  String? _required(String? value) {
    if ((value ?? '').trim().isEmpty) return 'This field is required.';
    return null;
  }

  String? _usernameValidator(String? value) {
    final username = (value ?? '').trim();
    if (username.isEmpty) return 'This field is required.';
    if (username.length < 3) return 'Use at least 3 characters.';
    return null;
  }

}

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 380),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(
          colors: [AppTheme.orange, Color(0xffff8a18)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('images/logo.png', width: 42, height: 42),
                  const SizedBox(width: 10),
                  const Text(
                    'Sahal Gas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fast. Safe.\nReliable.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Gas delivery, stock control, order tracking, and driver dispatch in one responsive web app.',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
              const Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  _FeaturePill(
                    icon: Icons.inventory_2_outlined,
                    text: 'Inventory',
                  ),
                  _FeaturePill(icon: Icons.route_outlined, text: 'Drivers'),
                  _FeaturePill(
                    icon: Icons.receipt_long_outlined,
                    text: 'Orders',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .18),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withValues(alpha: .18)),
      ),
      child: Text(message, style: const TextStyle(color: Colors.red)),
    );
  }
}

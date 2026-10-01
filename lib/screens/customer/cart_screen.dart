import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../core/formatters.dart';
import '../../models/payment_method.dart';
import '../../widgets/app_page.dart';
import '../../widgets/cylinder_illustration.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gas_cylinder_image.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressController = TextEditingController();
  String _paymentMethod = 'Cash on Delivery';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final cart = controller.cart;

    if (cart.isEmpty) {
      return AppPage(
        title: 'My Cart',
        child: const EmptyState(
          icon: Icons.shopping_cart_outlined,
          title: 'Your cart is empty',
          message: 'Add a gas cylinder to prepare a delivery order.',
        ),
      );
    }

    return AppPage(
      title: 'My Cart',
      child: Stack(
        children: [
          Positioned.fill(child: Container(color: const Color(0xfff0efee))),
          Positioned(
            left: 48,
            top: 90,
            child: Opacity(
              opacity: 0.12,
              child: _MiniTransportIcon(
                icon: Icons.local_gas_station_rounded,
                size: 72,
              ),
            ),
          ),
          Positioned(
            right: 42,
            top: 90,
            child: Opacity(
              opacity: 0.12,
              child: _MiniTransportIcon(
                icon: Icons.local_gas_station_rounded,
                size: 72,
              ),
            ),
          ),
          Positioned(
            left: 120,
            top: 220,
            child: Opacity(
              opacity: 0.12,
              child: _MiniTransportIcon(
                icon: Icons.local_shipping_rounded,
                size: 70,
              ),
            ),
          ),
          Positioned(
            right: 120,
            top: 220,
            child: Opacity(
              opacity: 0.12,
              child: _MiniTransportIcon(
                icon: Icons.local_shipping_rounded,
                size: 70,
              ),
            ),
          ),
          Positioned(
            left: 48,
            bottom: 150,
            child: Opacity(
              opacity: 0.12,
              child: _MiniTransportIcon(
                icon: Icons.local_gas_station_rounded,
                size: 72,
              ),
            ),
          ),
          Positioned(
            right: 42,
            bottom: 150,
            child: Opacity(
              opacity: 0.12,
              child: _MiniTransportIcon(
                icon: Icons.local_shipping_rounded,
                size: 70,
              ),
            ),
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
                child: Column(
                  children: [
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _DecorativeCartIcon(
                          icon: Icons.local_gas_station_rounded,
                          active: false,
                        ),
                        const SizedBox(width: 18),
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _DecorativeCartIcon(
                              icon: Icons.shopping_cart_rounded,
                              active: true,
                            ),
                            Positioned(
                              right: -8,
                              top: -8,
                              child: Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  color: Color(0xffd71920),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    '2',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 18),
                        _DecorativeCartIcon(
                          icon: Icons.local_shipping_rounded,
                          active: false,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Your Cart Items',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: const Color(0xff1f1f1f),
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.5,
                      ),
                    ),
                    const SizedBox(height: 18),
                    ...cart.map(
                      (line) => _CartItemCard(
                        line: line,
                        onDecrease: () => controller.updateCartQuantity(
                          line.cylinder.id,
                          line.quantity - 1,
                        ),
                        onIncrease: () => controller.updateCartQuantity(
                          line.cylinder.id,
                          line.quantity + 1,
                        ),
                        onRemove: () =>
                            controller.updateCartQuantity(line.cylinder.id, 0),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _SummaryCard(
                      addressController: _addressController,
                      paymentMethod: _paymentMethod,
                      onPaymentChanged: (value) =>
                          setState(() => _paymentMethod = value),
                      onPlaceOrder: controller.busy
                          ? null
                          : (paymentDetails) async {
                              if (_addressController.text.trim().isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Please enter a delivery address.',
                                    ),
                                  ),
                                );
                                return;
                              }
                              final ok = await controller.placeCartOrder(
                                deliveryAddress: _addressController.text.trim(),
                                paymentMethod: _paymentMethod,
                                paymentDetails: paymentDetails,
                              );
                              if (ok && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Order placed successfully.'),
                                  ),
                                );
                              }
                            },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorativeCartIcon extends StatelessWidget {
  const _DecorativeCartIcon({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final isCylinder = icon == Icons.local_gas_station_rounded;
    return Container(
      width: 110,
      height: 80,
      decoration: BoxDecoration(color: Colors.transparent),
      child: isCylinder
          ? CylinderIllustration(
              color: active ? const Color(0xffd71920) : const Color(0xffd9d0cd),
              size: 56,
            )
          : Icon(
              icon,
              size: 56,
              color: active ? const Color(0xffd71920) : const Color(0xffd9d0cd),
            ),
    );
  }
}

class _MiniTransportIcon extends StatelessWidget {
  const _MiniTransportIcon({required this.icon, required this.size});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    if (icon == Icons.local_gas_station_rounded) {
      return CylinderIllustration(color: const Color(0xffd7c9c4), size: size);
    }
    return Icon(icon, size: size, color: const Color(0xffd7c9c4));
  }
}

class _CartItemCard extends StatelessWidget {
  const _CartItemCard({
    required this.line,
    required this.onDecrease,
    required this.onIncrease,
    required this.onRemove,
  });

  final dynamic line;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              color: const Color(0xfff0f0f0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: GasCylinderImage(cylinder: line.cylinder, size: 88),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.cylinder.name,
                  style: const TextStyle(
                    color: Color(0xff1e1e1e),
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Item Type: ${line.cylinder.sizeKg}kg',
                  style: const TextStyle(
                    color: Color(0xff6a6a6a),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text(
                      'Quantity:',
                      style: TextStyle(
                        color: Color(0xff1f1f1f),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 14),
                    _QuantityStepper(
                      quantity: line.quantity,
                      onDecrease: onDecrease,
                      onIncrease: onIncrease,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Price: ${AppFormatters.money(line.cylinder.price)}',
                  style: const TextStyle(
                    color: Color(0xff1f1f1f),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            tooltip: 'Remove item',
            icon: const Icon(
              Icons.delete_outline_rounded,
              size: 28,
              color: Color(0xff1e1e1e),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int quantity;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xfff8f8f8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity <= 1 ? null : onDecrease,
            icon: const Icon(Icons.remove, size: 18),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
          ),
          SizedBox(
            width: 28,
            child: Center(
              child: Text(
                '$quantity',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff1f1f1f),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onIncrease,
            icon: const Icon(Icons.add, size: 18),
            constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatefulWidget {
  const _SummaryCard({
    required this.addressController,
    required this.paymentMethod,
    required this.onPaymentChanged,
    required this.onPlaceOrder,
  });

  final TextEditingController addressController;
  final String paymentMethod;
  final ValueChanged<String> onPaymentChanged;
  final Future<void> Function(Map<String, dynamic> paymentDetails)?
  onPlaceOrder;

  @override
  State<_SummaryCard> createState() => _SummaryCardState();
}

class _SummaryCardState extends State<_SummaryCard> {
  late MobileMoneyPayment _mobileMoneyPayment;
  late CardPayment _cardPayment;
  late CashOnDeliveryPayment _cashPayment;

  @override
  void initState() {
    super.initState();
    _mobileMoneyPayment = const MobileMoneyPayment(
      phoneNumber: '',
      provider: 'EVC Plus',
    );
    _cardPayment = const CardPayment(
      cardholderName: '',
      cardNumber: '',
      expiryMonth: '',
      expiryYear: '',
      cvv: '',
    );
    _cashPayment = const CashOnDeliveryPayment(notes: '');
  }

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    final estimatedTax = controller.cartSubtotal * 0.05;
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SummaryRow(label: 'Subtotal', value: controller.cartSubtotal),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Delivery Fee', value: controller.deliveryFee),
          const SizedBox(height: 8),
          _SummaryRow(label: 'Estimated Tax', value: estimatedTax),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: Color(0xff1f1f1f),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                AppFormatters.money(controller.cartTotal),
                style: const TextStyle(
                  color: Color(0xff1f1f1f),
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          TextField(
            controller: widget.addressController,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Delivery address',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          _PaymentMethodSelector(
            selectedMethod: widget.paymentMethod,
            onMethodChanged: widget.onPaymentChanged,
            mobileMoneyPayment: _mobileMoneyPayment,
            cardPayment: _cardPayment,
            cashPayment: _cashPayment,
            onMobileMoneyChanged: (payment) =>
                setState(() => _mobileMoneyPayment = payment),
            onCardChanged: (payment) => setState(() => _cardPayment = payment),
            onCashChanged: (payment) => setState(() => _cashPayment = payment),
          ),
          const SizedBox(height: 20),
          if (!isMobile)
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _submitPayment,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xffdf1c22),
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(58),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Proceed to Checkout',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitPayment,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xffdf1c22),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Proceed to Checkout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _submitPayment() async {
    Map<String, dynamic> paymentDetails;
    if (widget.paymentMethod == 'Mobile Money') {
      if (!_mobileMoneyPayment.isValid) {
        _showPaymentError('Enter a valid mobile money phone number.');
        return;
      }
      paymentDetails = {
        'status': 'paid',
        'reference': _demoReference('MM'),
        'account':
            '${_mobileMoneyPayment.provider}: ${_mobileMoneyPayment.phoneNumber}',
        'last4': null,
        'paidAt': DateTime.now().toIso8601String(),
      };
    } else if (widget.paymentMethod == 'Credit / Debit Card') {
      if (!_cardPayment.isValid) {
        _showPaymentError('Enter valid card details before checkout.');
        return;
      }
      paymentDetails = {
        'status': 'paid',
        'reference': _demoReference('CARD'),
        'account': _cardPayment.cardholderName.trim(),
        'last4': _cardPayment.cardNumber.substring(
          _cardPayment.cardNumber.length - 4,
        ),
        'paidAt': DateTime.now().toIso8601String(),
      };
    } else {
      paymentDetails = {
        'status': 'pending',
        'reference': _demoReference('COD'),
        'account': _cashPayment.notes.trim().isEmpty
            ? null
            : _cashPayment.notes.trim(),
        'last4': null,
        'paidAt': null,
      };
    }
    await widget.onPlaceOrder?.call(paymentDetails);
  }

  String _demoReference(String prefix) {
    return 'DEMO-$prefix-${DateTime.now().millisecondsSinceEpoch}';
  }

  void _showPaymentError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final dynamic value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xff2a2a2a),
            fontSize: 22,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Spacer(),
        Text(
          AppFormatters.money(value),
          style: const TextStyle(
            color: Color(0xff2a2a2a),
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _PaymentMethodSelector extends StatefulWidget {
  const _PaymentMethodSelector({
    required this.selectedMethod,
    required this.onMethodChanged,
    required this.mobileMoneyPayment,
    required this.cardPayment,
    required this.cashPayment,
    required this.onMobileMoneyChanged,
    required this.onCardChanged,
    required this.onCashChanged,
  });

  final String selectedMethod;
  final ValueChanged<String> onMethodChanged;
  final MobileMoneyPayment mobileMoneyPayment;
  final CardPayment cardPayment;
  final CashOnDeliveryPayment cashPayment;
  final ValueChanged<MobileMoneyPayment> onMobileMoneyChanged;
  final ValueChanged<CardPayment> onCardChanged;
  final ValueChanged<CashOnDeliveryPayment> onCashChanged;

  @override
  State<_PaymentMethodSelector> createState() => _PaymentMethodSelectorState();
}

class _PaymentMethodSelectorState extends State<_PaymentMethodSelector> {
  @override
  Widget build(BuildContext context) {
    final methods = [
      ('Cash on Delivery', Icons.payments_outlined),
      ('Mobile Money', Icons.phone_in_talk_outlined),
      ('Credit / Debit Card', Icons.credit_card_outlined),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Payment Method',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xff2a2a2a),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: methods.map((method) {
            final (methodName, icon) = method;
            final isSelected = widget.selectedMethod == methodName;
            return GestureDetector(
              onTap: () => widget.onMethodChanged(methodName),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xffdf1c22) : Colors.white,
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xffdf1c22)
                        : const Color(0xffd2d2d2),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xff2a2a2a),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      methodName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? Colors.white
                            : const Color(0xff2a2a2a),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 14),
        if (widget.selectedMethod == 'Mobile Money')
          _MobileMoneyForm(
            payment: widget.mobileMoneyPayment,
            onChanged: widget.onMobileMoneyChanged,
          )
        else if (widget.selectedMethod == 'Credit / Debit Card')
          _CardPaymentForm(
            payment: widget.cardPayment,
            onChanged: widget.onCardChanged,
          )
        else
          _CashOnDeliveryForm(
            payment: widget.cashPayment,
            onChanged: widget.onCashChanged,
          ),
      ],
    );
  }
}

class _MobileMoneyForm extends StatefulWidget {
  const _MobileMoneyForm({required this.payment, required this.onChanged});

  final MobileMoneyPayment payment;
  final ValueChanged<MobileMoneyPayment> onChanged;

  @override
  State<_MobileMoneyForm> createState() => _MobileMoneyFormState();
}

class _MobileMoneyFormState extends State<_MobileMoneyForm> {
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.payment.phoneNumber);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providers = ['EVC Plus', 'Hormuud', 'Telesom', 'Somtel', 'Golis'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Mobile Money Provider',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xff2a2a2a),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: widget.payment.provider,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.phone_in_talk),
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: providers
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (value) {
            if (value != null) {
              widget.onChanged(widget.payment.copyWith(provider: value));
            }
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            prefixIcon: Icon(Icons.phone),
            hintText: '252612345678',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            widget.onChanged(widget.payment.copyWith(phoneNumber: value));
          },
        ),
        const SizedBox(height: 12),
        TextField(
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Transaction PIN (Optional)',
            prefixIcon: Icon(Icons.lock),
            border: OutlineInputBorder(),
          ),
          obscureText: true,
          onChanged: (value) {
            widget.onChanged(
              widget.payment.copyWith(
                transactionPin: value.isEmpty ? null : value,
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xfff0eded),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffe0d7d4)),
          ),
          child: const Text(
            'Demo payment: your order will be marked paid and a transaction reference will be generated.',
            style: TextStyle(fontSize: 13, color: Color(0xff6a6a6a)),
          ),
        ),
      ],
    );
  }
}

class _CardPaymentForm extends StatefulWidget {
  const _CardPaymentForm({required this.payment, required this.onChanged});

  final CardPayment payment;
  final ValueChanged<CardPayment> onChanged;

  @override
  State<_CardPaymentForm> createState() => _CardPaymentFormState();
}

class _CardPaymentFormState extends State<_CardPaymentForm> {
  late TextEditingController _nameController;
  late TextEditingController _cardController;
  late TextEditingController _monthController;
  late TextEditingController _yearController;
  late TextEditingController _cvvController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.payment.cardholderName,
    );
    _cardController = TextEditingController(text: widget.payment.cardNumber);
    _monthController = TextEditingController(text: widget.payment.expiryMonth);
    _yearController = TextEditingController(text: widget.payment.expiryYear);
    _cvvController = TextEditingController(text: widget.payment.cvv);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cardController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String value) {
    value = value.replaceAll(RegExp(r'\D'), '');
    if (value.length > 16) value = value.substring(0, 16);
    return value;
  }

  String _formatDigits(String value, int maxLength) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    return digits.length > maxLength ? digits.substring(0, maxLength) : digits;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Cardholder Name',
            prefixIcon: Icon(Icons.person),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            widget.onChanged(widget.payment.copyWith(cardholderName: value));
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _cardController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Card Number',
            prefixIcon: Icon(Icons.credit_card),
            hintText: '1234567890123456',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            final formatted = _formatCardNumber(value);
            _cardController.value = _cardController.value.copyWith(
              text: formatted,
              selection: TextSelection.collapsed(offset: formatted.length),
            );
            widget.onChanged(widget.payment.copyWith(cardNumber: formatted));
          },
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              flex: 1,
              child: TextField(
                controller: _monthController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Month (MM)',
                  border: OutlineInputBorder(),
                  hintText: '01',
                ),
                onChanged: (value) {
                  final formatted = _formatDigits(value, 2);
                  _monthController.value = _monthController.value.copyWith(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                  widget.onChanged(
                    widget.payment.copyWith(expiryMonth: formatted),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: TextField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Year (YY)',
                  border: OutlineInputBorder(),
                  hintText: '25',
                ),
                onChanged: (value) {
                  final formatted = _formatDigits(value, 4);
                  _yearController.value = _yearController.value.copyWith(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                  widget.onChanged(
                    widget.payment.copyWith(expiryYear: formatted),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _cvvController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'CVV',
                  border: OutlineInputBorder(),
                  hintText: '123',
                ),
                obscureText: true,
                onChanged: (value) {
                  final formatted = _formatDigits(value, 4);
                  _cvvController.value = _cvvController.value.copyWith(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                  widget.onChanged(widget.payment.copyWith(cvv: formatted));
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xfff0eded),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffe0d7d4)),
          ),
          child: const Text(
            'Demo card payment: CVV is used only for validation and is never saved.',
            style: TextStyle(fontSize: 13, color: Color(0xff6a6a6a)),
          ),
        ),
      ],
    );
  }
}

class _CashOnDeliveryForm extends StatefulWidget {
  const _CashOnDeliveryForm({required this.payment, required this.onChanged});

  final CashOnDeliveryPayment payment;
  final ValueChanged<CashOnDeliveryPayment> onChanged;

  @override
  State<_CashOnDeliveryForm> createState() => _CashOnDeliveryFormState();
}

class _CashOnDeliveryFormState extends State<_CashOnDeliveryForm> {
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.payment.notes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xffe8f5e9),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffc8e6c9)),
          ),
          child: const Text(
            '✓ Pay when the driver delivers your order.\n💵 Have exact change ready.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xff2e7d32),
              height: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Special Instructions (Optional)',
            hintText: 'e.g., "Ring the bell twice" or "Leave at the door"',
            prefixIcon: Icon(Icons.note_outlined),
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            widget.onChanged(widget.payment.copyWith(notes: value));
          },
        ),
      ],
    );
  }
}

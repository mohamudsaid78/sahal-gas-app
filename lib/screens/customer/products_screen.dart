import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../app/app_theme.dart';
import '../../core/formatters.dart';
import '../../models/gas_cylinder.dart';
import '../../widgets/api_state.dart';
import '../../widgets/app_page.dart';
import '../../widgets/cylinder_card.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gas_cylinder_image.dart';
import '../../widgets/responsive_grid.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _search = '';
  int? _sizeKg;

  @override
  Widget build(BuildContext context) {
    final content = ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            SizedBox(
              width: 320,
              child: TextField(
                onChanged: (value) => setState(() => _search = value),
                decoration: const InputDecoration(
                  hintText: 'Search cylinders',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
            ),
            _FilterChip(label: 'All', selected: _sizeKg == null, onTap: () => setState(() => _sizeKg = null)),
            for (final size in [3, 6, 12, 15])
              _FilterChip(
                label: '$size KG',
                selected: _sizeKg == size,
                onTap: () => setState(() => _sizeKg = size),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ApiState<List<GasCylinder>>(
          future: AppScope.of(context).cylinderRepository.fetchCylinders(
            onlyActive: true,
            search: _search,
          ),
          isEmpty: (items) => items.isEmpty,
          empty: const EmptyState(
            icon: Icons.inventory_2_outlined,
            title: 'No cylinders found',
            message: 'Try another search or add cylinders from the admin panel.',
          ),
          builder: (context, cylinders) {
            final filtered = _sizeKg == null
                ? cylinders
                : cylinders.where((item) => item.sizeKg == _sizeKg).toList();
            if (filtered.isEmpty) {
              return const EmptyState(
                icon: Icons.filter_alt_off_outlined,
                title: 'No matching size',
                message: 'Choose another category to continue.',
              );
            }
            return ResponsiveGrid(
              minItemWidth: 220,
              mobileAspectRatio: .78,
              desktopAspectRatio: .95,
              children: filtered.map((cylinder) {
                return CylinderCard(
                  cylinder: cylinder,
                  onTap: () => showProductDetails(context, cylinder),
                  onAdd: () => AppScope.of(context, listen: false).addToCart(cylinder),
                );
              }).toList(),
            );
          },
        ),
      ],
    );

    if (widget.embedded) return content;
    return AppPage(
      title: 'Gas Cylinders',
      actions: [
        IconButton(
          tooltip: 'Refresh',
          onPressed: () => setState(() {}),
          icon: const Icon(Icons.refresh),
        ),
      ],
      child: RefreshIndicator(onRefresh: () async => setState(() {}), child: content),
    );
  }
}

void showProductDetails(BuildContext context, GasCylinder cylinder) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => _ProductDetails(cylinder: cylinder),
  );
}

class _ProductDetails extends StatefulWidget {
  const _ProductDetails({required this.cylinder});

  final GasCylinder cylinder;

  @override
  State<_ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<_ProductDetails> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final cylinder = widget.cylinder;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        18,
        18,
        18,
        MediaQuery.viewInsetsOf(context).bottom + 18,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 620),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: 'Close',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ),
            Center(child: GasCylinderImage(cylinder: cylinder, size: 150)),
            const SizedBox(height: 16),
            Text(
              cylinder.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text('${cylinder.sizeKg} KG cylinder for home and business delivery'),
            const SizedBox(height: 14),
            Text(
              AppFormatters.money(cylinder.price),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Quantity', style: TextStyle(fontWeight: FontWeight.w800)),
                const Spacer(),
                IconButton.outlined(
                  tooltip: 'Decrease quantity',
                  onPressed: _quantity == 1 ? null : () => setState(() => _quantity--),
                  icon: const Icon(Icons.remove),
                ),
                SizedBox(
                  width: 44,
                  child: Center(
                    child: Text('$_quantity', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                IconButton.outlined(
                  tooltip: 'Increase quantity',
                  onPressed: _quantity >= cylinder.stock ? null : () => setState(() => _quantity++),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(cylinder.description, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: cylinder.stock <= 0
                  ? null
                  : () {
                      AppScope.of(context, listen: false).addToCart(cylinder, quantity: _quantity);
                      Navigator.pop(context);
                    },
              icon: const Icon(Icons.shopping_cart_outlined),
              label: Text(cylinder.stock <= 0 ? 'Out of stock' : 'Add to cart'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      selectedColor: AppTheme.orange.withValues(alpha: .15),
      labelStyle: TextStyle(
        color: selected ? AppTheme.orange : null,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

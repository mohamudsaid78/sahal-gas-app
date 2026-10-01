import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../app/app_scope.dart';
import '../../database/database_helper.dart';
import '../../models/gas_cylinder.dart';
import '../../widgets/api_state.dart';
import '../../widgets/app_page.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/gas_cylinder_image.dart';
import 'admin_orders_screen.dart';

class AdminCylindersScreen extends StatefulWidget {
  const AdminCylindersScreen({super.key});

  @override
  State<AdminCylindersScreen> createState() => _AdminCylindersScreenState();
}

class _AdminCylindersScreenState extends State<AdminCylindersScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final controller = AppScope.of(context);
    return AppPage(
      title: 'Manage Cylinders',
      actions: [
        IconButton.filled(
          tooltip: 'Add cylinder',
          onPressed: () => _showCylinderForm(context),
          icon: const Icon(Icons.add, size: 26),
          style: IconButton.styleFrom(
            backgroundColor: const Color(0xffff6b3d),
            foregroundColor: Colors.white,
            minimumSize: const Size(42, 42),
          ),
        ),
      ],
      child: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xffe8e2df)),
              ),
              child: TextField(
                onChanged: (value) => setState(() => _search = value),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Search cylinders',
                  prefixIcon: Icon(Icons.search, color: Colors.black54, size: 24),
                  hintStyle: TextStyle(fontSize: 18, color: Color(0xff6d6d6d)),
                  contentPadding: EdgeInsets.symmetric(vertical: 16),
                ),
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 14),
            ApiState<List<GasCylinder>>(
              future: controller.cylinderRepository.fetchCylinders(search: _search),
              isEmpty: (items) => items.isEmpty,
              empty: const EmptyState(
                icon: Icons.inventory_2_outlined,
                title: 'No cylinders yet',
                message: 'Create the first gas cylinder product.',
              ),
              builder: (context, cylinders) {
                final lowStockCount = cylinders.where((c) => c.stock <= 3).length;
                final isMobile = MediaQuery.of(context).size.width < 900;

                return Column(
                  children: [
                    if (lowStockCount > 0) _lowStockNotice(lowStockCount),
                    ...cylinders.map((cylinder) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xffe7e0df)),
                        ),
                        child: isMobile
                            ? _buildMobileCylinderCard(context, cylinder)
                            : _buildDesktopCylinderCard(context, cylinder),
                      );
                    }),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopCylinderCard(BuildContext context, GasCylinder cylinder) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 110,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Transform.translate(
              offset: const Offset(0, 6),
              child: GasCylinderImage(cylinder: cylinder, size: 96),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cylinder Product Name',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                cylinder.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: Color(0xff1c1c1c),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${cylinder.sizeKg} KG Size | Model: X-Series',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xff3d3d3d),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Status: ${cylinder.active ? 'Active' : 'Inactive'}',
                style: TextStyle(
                  fontSize: 15,
                  color: cylinder.active ? Colors.green.shade700 : Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(
                    'IN STOCK: ${cylinder.stock}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xff1f1f1f),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: cylinder.stock > 0 ? Colors.green : Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _actionRow('View Details', Icons.visibility_outlined, () => _showCylinderDetails(context, cylinder)),
              const SizedBox(height: 6),
              _actionRow('Edit Product', Icons.edit_outlined, () => _showCylinderForm(context, cylinder: cylinder)),
              const SizedBox(height: 6),
              _actionRow('Manage Stock', Icons.inventory_2_outlined, () => _showStockEditor(context, cylinder)),
              const SizedBox(height: 6),
              _actionRow('View Order History', Icons.history, () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
                );
              }),
              const SizedBox(height: 6),
              _actionRow(
                cylinder.active ? 'Deactivate' : 'Activate',
                cylinder.active ? Icons.block_rounded : Icons.check_circle_outline,
                () async {
                  final controller = AppScope.of(context);
                  await controller.cylinderRepository.updateCylinder(
                    cylinder.copyWith(active: !cylinder.active),
                  );
                  if (context.mounted) setState(() {});
                },
              ),
              const SizedBox(height: 6),
              _actionRow(
                'Delete Product',
                Icons.delete_outline,
                () => _confirmDelete(context, cylinder),
                color: Colors.red.shade700,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileCylinderCard(BuildContext context, GasCylinder cylinder) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 90,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Transform.translate(
                  offset: const Offset(0, 4),
                  child: GasCylinderImage(cylinder: cylinder, size: 70),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cylinder Product Name',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.black.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cylinder.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xff1c1c1c),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${cylinder.sizeKg} KG | X-Series',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xff3d3d3d),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Status: ${cylinder.active ? 'Active' : 'Inactive'}',
                    style: TextStyle(
                      fontSize: 12,
                      color: cylinder.active ? Colors.green.shade700 : Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        'Stock: ${cylinder.stock}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xff1f1f1f),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: cylinder.stock > 0 ? Colors.green : Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            _actionRowCompact('Details', Icons.visibility_outlined, () => _showCylinderDetails(context, cylinder)),
            _actionRowCompact('Edit', Icons.edit_outlined, () => _showCylinderForm(context, cylinder: cylinder)),
            _actionRowCompact('Stock', Icons.inventory_2_outlined, () => _showStockEditor(context, cylinder)),
            _actionRowCompact('History', Icons.history, () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AdminOrdersScreen()),
              );
            }),
            _actionRowCompact(
              cylinder.active ? 'Deactivate' : 'Activate',
              cylinder.active ? Icons.block_rounded : Icons.check_circle_outline,
              () async {
                final controller = AppScope.of(context);
                await controller.cylinderRepository.updateCylinder(
                  cylinder.copyWith(active: !cylinder.active),
                );
                if (context.mounted) setState(() {});
              },
            ),
            _actionRowCompact(
              'Delete',
              Icons.delete_outline,
              () => _confirmDelete(context, cylinder),
              color: Colors.red.shade700,
            ),
          ],
        ),
      ],
    );
  }

  Widget _lowStockNotice(int count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xfff7efe9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xfff0d4cc)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xfff15a3c),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Low Stock',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xff2d2d2d),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xfff15a3c),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      '! Needs attention',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xfff15a3c),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xff2b2b2b), size: 34),
        ],
      ),
    );
  }

  Widget _actionRow(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    Color color = const Color(0xff2b2b2b),
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 17,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionRowCompact(
    String label,
    IconData icon,
    VoidCallback onPressed, {
    Color color = const Color(0xff2b2b2b),
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCylinderDetails(BuildContext context, GasCylinder cylinder) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: GasCylinderImage(cylinder: cylinder, size: 120)),
            const SizedBox(height: 16),
            Text(
              cylinder.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text('${cylinder.sizeKg} KG Size | Model: X-Series'),
            const SizedBox(height: 8),
            Text('Status: ${cylinder.active ? 'Active' : 'Inactive'}'),
            const SizedBox(height: 8),
            Text('Description: ${cylinder.description.isEmpty ? 'No description' : cylinder.description}'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
              label: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    GasCylinder cylinder,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product?'),
        content: Text(
          'Delete ${cylinder.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await AppScope.of(context, listen: false)
          .cylinderRepository
          .deleteCylinder(cylinder.id);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${cylinder.name} deleted.')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not delete this product.')),
      );
    }
  }
  

  void _showStockEditor(BuildContext context, GasCylinder cylinder) {
    final controller = AppScope.of(context, listen: false);
    final stockController = TextEditingController(text: cylinder.stock.toString());
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => Padding(
        padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.viewInsetsOf(sheetContext).bottom + 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Manage Stock',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Available stock',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                final value = int.tryParse(stockController.text.trim()) ?? cylinder.stock;
                await controller.cylinderRepository.updateCylinder(
                  cylinder.copyWith(stock: value),
                );
                if (context.mounted) setState(() {});
                if (sheetContext.mounted) Navigator.of(sheetContext).pop();
              },
              icon: const Icon(Icons.save_outlined),
              label: const Text('Save stock'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCylinderForm(BuildContext context, {GasCylinder? cylinder}) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
        backgroundColor: Colors.transparent,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isMobile ? screenWidth - 36 : 900,
            maxHeight: MediaQuery.of(context).size.height - 48,
          ),
          child: _CylinderForm(
            cylinder: cylinder,
            onSaved: () => setState(() {}),
          ),
        ),
      ),
    );
  }
}

class _CylinderForm extends StatefulWidget {
  const _CylinderForm({required this.onSaved, this.cylinder});

  final GasCylinder? cylinder;
  final VoidCallback onSaved;

  @override
  State<_CylinderForm> createState() => _CylinderFormState();
}

class _CylinderFormState extends State<_CylinderForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _sizeController;
  late final TextEditingController _priceController;
  late final TextEditingController _stockController;
  late final TextEditingController _descriptionController;
  String _colorHex = '#ff4b14';
  bool _active = true;
  String? _imageUrl;
  Uint8List? _imageBytes;
  bool _uploadingImage = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final cylinder = widget.cylinder;
    _nameController = TextEditingController(text: cylinder?.name ?? '12 KG Cylinder');
    _sizeController = TextEditingController(text: '${cylinder?.sizeKg ?? 12}');
    _priceController = TextEditingController(text: '${cylinder?.price ?? 15}');
    _stockController = TextEditingController(text: '${cylinder?.stock ?? 20}');
    _descriptionController = TextEditingController(
      text: cylinder?.description ?? 'Gas cylinder suitable for home and commercial use.',
    );
    _colorHex = cylinder?.colorHex ?? '#ff4b14';
    _active = cylinder?.active ?? true;
    _imageUrl = cylinder?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _sizeController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.cylinder != null;
    final colorOptions = ['#ff4b14', '#0877c9', '#d91c12', '#5d7f28'];
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xfff4efee),
        border: Border.all(color: const Color(0xffd9d1cf)),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 18),
            decoration: const BoxDecoration(
              color: Color(0xfff1493c),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(14),
                topRight: Radius.circular(14),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    editing ? 'Edit Cylinder Product: ${widget.cylinder?.name ?? ''}' : 'Create Cylinder Product',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: Colors.white),
                  tooltip: 'Close',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          Flexible(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: isMobile
                      ? _buildMobileForm(colorOptions)
                      : _buildDesktopForm(colorOptions),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopForm(List<String> colorOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 220,
              child: Column(
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xfff5f1ef),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Center(
                      child: _imagePreview(size: 120),
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _uploadingImage ? null : _pickImage,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff2d2d2d),
                        side: const BorderSide(color: Color(0xffd9d1cf)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _uploadingImage
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text(
                              'Change Image',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 22),
            Expanded(
              child: _buildFormFields(colorOptions),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileForm(List<String> colorOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              Container(
                width: 150,
                height: 150,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xfff5f1ef),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: _imagePreview(size: 100),
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _uploadingImage ? null : _pickImage,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xff2d2d2d),
                    side: const BorderSide(color: Color(0xffd9d1cf)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _uploadingImage
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Change Image',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _buildFormFields(colorOptions),
      ],
    );
  }

  Widget _buildFormFields(List<String> colorOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FieldLabel(label: 'Product Name'),
        _TextInputBox(controller: _nameController, validator: _required),
        const SizedBox(height: 12),
        _FieldLabel(label: 'Size / Weight'),
        _TextInputBox(
          controller: _sizeController,
          keyboardType: TextInputType.number,
          validator: _positiveInteger,
        ),
        const SizedBox(height: 12),
        _FieldLabel(label: 'Model'),
        _TextInputBox(controller: TextEditingController(text: 'X-Series'), readOnly: true),
        const SizedBox(height: 12),
        _FieldLabel(label: 'Status'),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xffd7d3d1)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<bool>(
              value: _active,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              items: const [
                DropdownMenuItem(value: true, child: Text('Active')),
                DropdownMenuItem(value: false, child: Text('Inactive')),
              ],
              onChanged: (value) => setState(() => _active = value ?? true),
            ),
          ),
        ),
        const SizedBox(height: 12),
        _FieldLabel(label: 'Unit Price'),
        _TextInputBox(
          controller: _priceController,
          keyboardType: TextInputType.number,
          validator: _required,
        ),
        const SizedBox(height: 12),
        _FieldLabel(label: 'Supplier'),
        _TextInputBox(controller: TextEditingController(text: 'Sahal Energy Co.'), readOnly: true),
        const SizedBox(height: 12),
        _FieldLabel(label: 'Description'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xffd7d3d1)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextFormField(
            controller: _descriptionController,
            minLines: 3,
            maxLines: 5,
            style: const TextStyle(fontSize: 16, color: Color(0xff2e2e2e)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(height: 18),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: colorOptions.map((color) {
              final selected = _colorHex == color;
              final parsed = GasCylinder(
                id: '',
                name: '',
                sizeKg: 0,
                price: 0,
                stock: 0,
                colorHex: color,
                description: '',
                active: true,
              ).color;
              return GestureDetector(
                onTap: () => setState(() => _colorHex = color),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xfff5f0ee) : Colors.white,
                    border: Border.all(
                      color: selected ? const Color(0xffd3c7c2) : const Color(0xffd7d3d1),
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: parsed,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        color,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xff2b2b2b),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            const Text(
              'Visible to customers',
              style: TextStyle(fontSize: 16, color: Color(0xff2b2b2b)),
            ),
            const Spacer(),
            Switch(
              value: _active,
              onChanged: (value) => setState(() => _active = value),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            Flexible(
              child: FilledButton(
                onPressed: _saving || _uploadingImage ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xfff06b3c),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_saving)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    else ...[
                      const Icon(Icons.save_alt_rounded),
                      const SizedBox(width: 10),
                      const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Flexible(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xff2c2c2c),
                  side: const BorderSide(color: Color(0xffd7d3d1)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final size = int.tryParse(_sizeController.text.trim());
    final price = double.tryParse(_priceController.text.trim());
    final stock = int.tryParse(_stockController.text.trim());
    if (size == null || size <= 0 || price == null || price < 0 || stock == null || stock < 0) {
      return;
    }

    setState(() => _saving = true);
    final repo = AppScope.of(context, listen: false).cylinderRepository;
    final cylinder = GasCylinder(
      id: widget.cylinder?.id ?? '',
      name: _nameController.text.trim(),
      sizeKg: size,
      price: price,
      stock: stock,
      colorHex: _colorHex,
      description: _descriptionController.text.trim(),
      active: _active,
      imageUrl: _imageUrl,
    );
    try {
      if (widget.cylinder == null) {
        await repo.createCylinder(cylinder);
      } else {
        await repo.updateCylinder(cylinder);
      }
    } catch (error) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save cylinder: $error')),
        );
      }
      return;
    }
    widget.onSaved();
    if (mounted) Navigator.pop(context);
  }

  String? _required(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Required';
    return null;
  }

  String? _positiveInteger(String? value) {
    final parsed = int.tryParse((value ?? '').trim());
    if (parsed == null || parsed <= 0) return 'Enter a number greater than 0';
    return null;
  }

  Widget _imagePreview({required double size}) {
    final cylinder = GasCylinder(
      id: '',
      name: '',
      sizeKg: 0,
      price: 0,
      stock: 0,
      colorHex: _colorHex,
      description: '',
      active: true,
      imageUrl: _imageUrl,
    );
    if (_imageBytes != null) {
      return Image.memory(_imageBytes!, width: size, height: size, fit: BoxFit.contain);
    }
    return GasCylinderImage(cylinder: cylinder, size: size);
  }

  Future<void> _pickImage() async {
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      allowMultiple: false,
      withData: true,
    );
    if (result == null || result.files.isEmpty || !mounted) return;

    final file = result.files.single;
    final bytes = file.bytes;
    if (bytes == null) return;
    setState(() {
      _imageBytes = bytes;
      _uploadingImage = true;
    });
    try {
      final userId = AppScope.of(context, listen: false).currentUser?.id ?? 'admin';
      final response = await DatabaseHelper.uploadFile(
        file.name,
        userId,
        bytes,
        'cylinder',
      );
      final map = response is Map ? Map<String, dynamic>.from(response) : <String, dynamic>{};
      final uploadedUrl = map['url'] ?? map['file_url'] ?? map['path'] ?? map['location'];
      if (uploadedUrl is! String || uploadedUrl.trim().isEmpty) {
        throw Exception('Upload response did not include an image URL.');
      }
      if (mounted) {
        setState(() {
          _imageUrl = uploadedUrl.trim();
          _uploadingImage = false;
        });
      }
    } catch (error) {
      if (!mounted) return;
      setState(() => _uploadingImage = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Image upload failed: $error')),
      );
    }
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: const TextStyle(fontSize: 15, color: Color(0xff2b2b2b)),
      ),
    );
  }
}

class _TextInputBox extends StatelessWidget {
  const _TextInputBox({
    required this.controller,
    this.validator,
    this.keyboardType,
    this.readOnly = false,
  });

  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xffd7d3d1)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 18, color: Color(0xff2b2b2b)),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          isDense: true,
        ),
      ),
    );
  }
}


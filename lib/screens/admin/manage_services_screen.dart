import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/models/service_model.dart';

class ManageServicesScreen extends StatefulWidget {
  const ManageServicesScreen({super.key});

  @override
  State<ManageServicesScreen> createState() => _ManageServicesScreenState();
}

class _ManageServicesScreenState extends State<ManageServicesScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showServiceDialog({ServiceModel? service}) {
    final nameController = TextEditingController(text: service?.name ?? '');
    final descController = TextEditingController(text: service?.description ?? '');
    final priceController = TextEditingController(
      text: service?.price.toStringAsFixed(0) ?? '',
    );
    final durationController = TextEditingController(
      text: service?.durationMinutes.toString() ?? '',
    );
    final vehicleController = TextEditingController(
      text: service?.vehicleType ?? 'All Types',
    );
    final isEdit = service != null;
    String category = service?.category ?? 'Basic';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppColors.cardDark,
          title: Text(isEdit ? 'Edit Service' : 'Add Service', style: AppTextStyles.title),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(labelText: 'Service Name *'),
                ),
                TextField(
                  controller: descController,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: priceController,
                  style: AppTextStyles.body,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price *'),
                ),
                TextField(
                  controller: durationController,
                  style: AppTextStyles.body,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Duration (mins) *'),
                ),
                TextField(
                  controller: vehicleController,
                  style: AppTextStyles.body,
                  decoration: const InputDecoration(labelText: 'Vehicle Type *'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: category,
                  dropdownColor: AppColors.cardDark,
                  style: AppTextStyles.body,
                  items: ['Basic', 'Premium', 'Interior', 'Detailing']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => category = v ?? 'Basic'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Service name is required.')),
                  );
                  return;
                }
                final price = double.tryParse(priceController.text);
                if (price == null || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid price.')),
                  );
                  return;
                }
                final duration = int.tryParse(durationController.text);
                if (duration == null || duration <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Enter a valid duration.')),
                  );
                  return;
                }
                if (vehicleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vehicle type is required.')),
                  );
                  return;
                }

                final state = context.read<AppState>();
                if (isEdit) {
                  await state.editService(service.copyWith(
                    name: nameController.text.trim(),
                    description: descController.text.trim(),
                    price: price,
                    durationMinutes: duration,
                    vehicleType: vehicleController.text.trim(),
                    category: category,
                  ));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Service updated successfully.')),
                    );
                  }
                } else {
                  final id = 's${DateTime.now().millisecondsSinceEpoch}';
                  await state.addService(ServiceModel(
                    id: id,
                    name: nameController.text.trim(),
                    description: descController.text.trim().isEmpty
                        ? 'No description'
                        : descController.text.trim(),
                    price: price,
                    durationMinutes: duration,
                    vehicleType: vehicleController.text.trim(),
                    category: category,
                    createdAt: DateTime.now(),
                  ));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Service added successfully.')),
                    );
                  }
                }
                if (context.mounted) Navigator.pop(ctx);
              },
              child: Text(isEdit ? 'Save' : 'Add', style: const TextStyle(color: AppColors.cyan)),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteService(ServiceModel service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        title: Text('Delete Service', style: AppTextStyles.title),
        content: Text('Delete "${service.name}"?', style: AppTextStyles.body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              await context.read<AppState>().deleteService(service.id);
              if (!context.mounted) return;
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Service deleted.')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: AppColors.dangerRed)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allServices = context.watch<AppState>().availableServices;
    final q = _searchController.text.toLowerCase();
    final services = q.isEmpty
        ? allServices
        : allServices.where((s) => s.name.toLowerCase().contains(q)).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Manage Services', style: AppTextStyles.headline.copyWith(fontSize: 24)),
              IconButton(
                onPressed: () => _showServiceDialog(),
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.add, color: AppColors.textLight, size: 20),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            style: AppTextStyles.body,
            decoration: InputDecoration(
              hintText: 'Search services...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
              filled: true,
              fillColor: AppColors.cardDark,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final s = services[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name, style: AppTextStyles.title.copyWith(fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(s.description, style: AppTextStyles.caption, maxLines: 2),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _Badge(label: '₱${s.price.toStringAsFixed(0)}', color: AppColors.aquaBlue),
                        const SizedBox(width: 8),
                        _Badge(label: '${s.durationMinutes} min', color: AppColors.cyan),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _showServiceDialog(service: s),
                            icon: const Icon(Icons.edit_outlined, size: 16),
                            label: const Text('Edit'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.cyan,
                              side: const BorderSide(color: AppColors.cyan),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => _deleteService(s),
                            icon: const Icon(Icons.delete_outline, size: 16),
                            label: const Text('Delete'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.dangerRed,
                              side: const BorderSide(color: AppColors.dangerRed),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: AppTextStyles.badge.copyWith(color: color)),
    );
  }
}

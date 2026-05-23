import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:washgo/core/constants/app_colors.dart';
import 'package:washgo/core/constants/app_text_styles.dart';
import 'package:washgo/core/constants/app_constants.dart';
import 'package:washgo/core/state/app_state.dart';
import 'package:washgo/core/widgets/custom_button.dart';
import 'package:washgo/core/widgets/custom_text_field.dart';
import 'package:washgo/models/service_model.dart';
import 'package:washgo/screens/user/qr_receipt_screen.dart';

class BookingScreen extends StatefulWidget {
  final ServiceModel? service;

  const BookingScreen({super.key, this.service});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late ServiceModel _selectedService;
  String _vehicleType = 'Sedan';
  final _plateController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);

  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    final services = context.read<AppState>().availableServices;
    if (services.isNotEmpty) {
      _selectedService = widget.service ?? services.first;
    }
    _vehicleType = AppConstants.vehicleTypes.first;
    _initialized = true;
  }

  @override
  void dispose() {
    _plateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.aquaBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.dark(primary: AppColors.aquaBlue),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Future<void> _confirmBooking() async {
    if (_plateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your plate number.')),
      );
      return;
    }

    final state = context.read<AppState>();
    final booking = await state.createBooking(
      service: _selectedService,
      vehicleType: _vehicleType,
      plateNumber: _plateController.text.trim(),
      bookingDate: _formatDate(_selectedDate),
      bookingTime: _selectedTime.format(context),
      notes: _notesController.text,
    );

    if (!mounted) return;
    if (booking == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.errorMessage ?? 'Unable to create booking. Please log in again.',
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking created successfully!')),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => QRReceiptScreen(booking: booking)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = context.watch<AppState>().availableServices;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.screenBackgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textLight),
                    ),
                    Text('Book a Wash', style: AppTextStyles.title),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _ServiceSelector(
                        services: services,
                        selected: _selectedService,
                        onChanged: (s) => setState(() => _selectedService = s),
                      ),
                      const SizedBox(height: 20),
                      Text('Vehicle Type', style: AppTextStyles.caption.copyWith(fontSize: 13)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AppConstants.vehicleTypes.map((type) {
                          final selected = _vehicleType == type;
                          return ChoiceChip(
                            label: Text(type),
                            selected: selected,
                            onSelected: (_) => setState(() => _vehicleType = type),
                            selectedColor: AppColors.aquaBlue.withValues(alpha: 0.25),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Plate Number',
                        hint: 'e.g. ABC 1234',
                        prefixIcon: Icons.pin_outlined,
                        controller: _plateController,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _PickerTile(
                              label: 'Date',
                              value: _formatDate(_selectedDate),
                              icon: Icons.calendar_today_outlined,
                              onTap: _pickDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _PickerTile(
                              label: 'Time',
                              value: _selectedTime.format(context),
                              icon: Icons.access_time_outlined,
                              onTap: _pickTime,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Notes (optional)',
                        hint: 'Special instructions...',
                        prefixIcon: Icons.note_outlined,
                        controller: _notesController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      _SummaryCard(
                        service: _selectedService,
                        vehicleType: _vehicleType,
                        plate: _plateController.text,
                        date: _formatDate(_selectedDate),
                        time: _selectedTime.format(context),
                      ),
                      const SizedBox(height: 24),
                      CustomButton(
                        text: 'Confirm Booking',
                        icon: Icons.check_circle_outline,
                        onPressed: _confirmBooking,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceSelector extends StatelessWidget {
  final List<ServiceModel> services;
  final ServiceModel selected;
  final ValueChanged<ServiceModel> onChanged;

  const _ServiceSelector({
    required this.services,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Selected Service', style: AppTextStyles.caption.copyWith(fontSize: 13)),
          const SizedBox(height: 8),
          DropdownButtonFormField<ServiceModel>(
            initialValue: services.contains(selected) ? selected : services.firstOrNull,
            dropdownColor: AppColors.cardDark,
            style: AppTextStyles.body,
            decoration: const InputDecoration(border: InputBorder.none),
            items: services
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text('${s.name} — ₱${s.price.toStringAsFixed(0)}'),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) onChanged(v);
            },
          ),
        ],
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final VoidCallback onTap;

  const _PickerTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.cardDark,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppColors.cyan),
                const SizedBox(width: 6),
                Text(label, style: AppTextStyles.caption),
              ],
            ),
            const SizedBox(height: 6),
            Text(value, style: AppTextStyles.body.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final ServiceModel service;
  final String vehicleType;
  final String plate;
  final String date;
  final String time;

  const _SummaryCard({
    required this.service,
    required this.vehicleType,
    required this.plate,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.heroCardGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Booking Summary',
            style: AppTextStyles.title.copyWith(
              fontSize: 16,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          _row('Service', service.name),
          _row('Vehicle', vehicleType),
          _row('Plate', plate.isEmpty ? '—' : plate),
          _row('Date', date),
          _row('Time', time),
          Divider(color: Colors.white.withValues(alpha: 0.25)),
          _row('Total', '₱${service.price.toStringAsFixed(0)}', bold: true),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.caption.copyWith(
              color: AppColors.textLight.withValues(alpha: 0.85),
            ),
          ),
          Text(
            value,
            style: bold
                ? AppTextStyles.title.copyWith(
                    fontSize: 16,
                    color: AppColors.textLight,
                  )
                : AppTextStyles.body.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
          ),
        ],
      ),
    );
  }
}

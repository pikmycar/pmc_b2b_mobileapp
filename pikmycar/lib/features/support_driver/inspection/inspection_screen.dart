import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class SupportDriverInspectionScreen extends StatefulWidget {
  const SupportDriverInspectionScreen({Key? key}) : super(key: key);

  @override
  State<SupportDriverInspectionScreen> createState() => _SupportDriverInspectionScreenState();
}

class _SupportDriverInspectionScreenState extends State<SupportDriverInspectionScreen> {
  final Map<String, bool> _inspectionItems = {
    'Exterior (Scratches/Dents)': false,
    'Tires alignment & pressure': false,
    'Interior cleanliness': false,
    'Fuel level checked': false,
    'All lights working': false,
  };

  bool get _allChecked => _inspectionItems.values.every((v) => v);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Car Inspection')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            color: Theme.of(context).colorScheme.surface,
            child: Row(
              children: [
                Icon(Icons.directions_car, size: 48, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Customer Vehicle', style: AppTextStyles.heading4),
                      Text('Honda Civic • XYZ-9876', style: AppTextStyles.labelSmall),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Row(
              children: [
                Text(
                  'Pre-Trip Checklist',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '\${_inspectionItems.values.where((v) => v).length}/\${_inspectionItems.length}',
                  style: AppTextStyles.subtitle.copyWith(color: AppColors.infoBlue),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _inspectionItems.keys.map((key) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: CheckboxListTile(
                    title: Text(key, style: AppTextStyles.subtitle.copyWith(fontWeight: FontWeight.w500)),
                    value: _inspectionItems[key],
                    activeColor: AppColors.success,
                    onChanged: (val) {
                      setState(() {
                        _inspectionItems[key] = val ?? false;
                      });
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _allChecked ? AppColors.success : AppColors.textSecondary,
                ),
                onPressed: _allChecked ? () {
                  // Drive to garage phase
                  Navigator.pushReplacementNamed(context, '/support_driver_garage_delivery');
                } : null,
                child: const Text('Start Trip to Garage'),
              ),
            ),
          )
        ],
      ),
    );
  }
}

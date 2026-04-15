import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';

class SupportDriverInspectionScreen extends StatefulWidget {
  const SupportDriverInspectionScreen({Key? key}) : super(key: key);

  @override
  State<SupportDriverInspectionScreen> createState() =>
      _SupportDriverInspectionScreenState();
}

class _SupportDriverInspectionScreenState
    extends State<SupportDriverInspectionScreen> {
  final ImagePicker _picker = ImagePicker();

  final List<String> _inspectionItems = [
    'Exterior (Scratches/Dents)',
    'Tires alignment & pressure',
    'Interior cleanliness',
    'Fuel level checked',
    'All lights working',
  ];

  // YES / NO
  final Map<String, String?> _inspectionAnswers = {};

  // Images (optional)
  final Map<String, List<File>> _inspectionImages = {};

  bool get _allAnswered =>
      _inspectionItems.every((key) =>
          _inspectionAnswers[key] != null);

  Future<void> _pickImage(String key) async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _inspectionImages.putIfAbsent(key, () => []);
        _inspectionImages[key]!.add(File(picked.path));
      });
    }
  }

  void _removeImage(String key, int index) {
    setState(() {
      _inspectionImages[key]?.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final canProceed = _allAnswered;

    return Scaffold(
      appBar: AppBar(title: const Text('Car Inspection')),
      body: Column(
        children: [
          // 🚗 Vehicle Info
          Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Row(
              children: [
                Icon(Icons.directions_car,
                    size: 42,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Customer Vehicle',
                        style: AppTextStyles.heading4),
                    Text('Honda Civic • XYZ-9876',
                        style: AppTextStyles.labelSmall),
                  ],
                )
              ],
            ),
          ),

          // 🧾 Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  'Pre-Trip Checklist',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${_inspectionAnswers.values.where((v) => v != null).length}/${_inspectionItems.length}',
                  style: TextStyle(
                      color: AppColors.infoBlue,
                      fontWeight: FontWeight.w600),
                )
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 📋 List
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: _inspectionItems.map((key) {
                final images = _inspectionImages[key] ?? [];

                return Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 6,
                        color: Colors.black.withOpacity(0.05),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 📝 Title
                      Text(
                        key,
                        style: AppTextStyles.subtitle
                            .copyWith(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 10),

                      // 👍 YES / NO
                      Row(
                        children: [
                          ChoiceChip(
                            label: const Text("Yes"),
                            selected: _inspectionAnswers[key] == "yes",
                            selectedColor: Colors.green,
                            onSelected: (_) {
                              setState(() {
                                _inspectionAnswers[key] = "yes";
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          ChoiceChip(
                            label: const Text("No"),
                            selected: _inspectionAnswers[key] == "no",
                            selectedColor: Colors.red,
                            onSelected: (_) {
                              setState(() {
                                _inspectionAnswers[key] = "no";
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      // 📸 Optional Image
                      ElevatedButton.icon(
                        onPressed: () => _pickImage(key),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text("Upload Photo (Optional)"),
                      ),

                      const SizedBox(height: 10),

                      // 🖼 Preview
                      if (images.isNotEmpty)
                        SizedBox(
                          height: 80,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: images.length,
                            itemBuilder: (_, i) {
                              return Stack(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(right: 10),
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(10),
                                      image: DecorationImage(
                                        image: FileImage(images[i]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 0,
                                    right: 6,
                                    child: GestureDetector(
                                      onTap: () =>
                                          _removeImage(key, i),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        child: const Icon(Icons.close,
                                            size: 16,
                                            color: Colors.white),
                                      ),
                                    ),
                                  )
                                ],
                              );
                            },
                          ),
                        )
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // 🚀 Button
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(14),
                  backgroundColor:
                      canProceed ? AppColors.success : Colors.grey,
                ),
                onPressed: canProceed
                    ? () {
                        Navigator.pushReplacementNamed(
                            context,
                            '/support_driver_garage_delivery');
                      }
                    : null,
                child: const Text('Start Trip to Garage'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
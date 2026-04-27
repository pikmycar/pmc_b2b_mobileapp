import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_theme.dart';

class SupportDriverInspectionScreen extends StatefulWidget {
  const SupportDriverInspectionScreen({super.key});

  @override
  State<SupportDriverInspectionScreen> createState() =>
      _SupportDriverInspectionScreenState();
}

class _SupportDriverInspectionScreenState
    extends State<SupportDriverInspectionScreen> {
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();
  int _currentStep = 0;

  // STEP 1 STATE: Exterior
  bool _noScratches = true;
  bool _lightsWorking = true;
  bool _tyreOk = true;
  bool _windscreenOk = false;
  bool _bodyPanelsOk = true;
  final TextEditingController _damageNotesController = TextEditingController();

  // STEP 2 STATE: Interior
  bool _seatsOk = true;
  bool _dashboardOk = true;
  bool _keysReceived = true;
  bool _noValuables = false;
  final TextEditingController _odometerController = TextEditingController(text: "42,810 km");
  double _fuelLevel = 0.6; // ~60% Full

  // STEP 3 STATE: Photos
  final Map<String, File?> _capturedPhotos = {
    'Front': null,
    'Back': null,
    'Left': null,
    'Right Side': null,
    'Odometer': null,
    'Interior': null,
  };

  int get _photosCount => _capturedPhotos.values.where((f) => f != null).length;

  Future<bool> _onBackPressed(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Cancel Trip?"),
        content: const Text("Are you sure you want to cancel this trip?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("No"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Yes"),
          ),
        ],
      ),
    );

    if (result == true) {
      if (!mounted) return true;
      Navigator.pushNamedAndRemoveUntil(context, '/support_driver_dashboard', (route) => false);
      return true;
    }
    return false;
  }

  void _nextPage() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Final Handover logic
      Navigator.pushReplacementNamed(context, '/support_driver_handover');
    }
  }

  void _previousPage() async {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _onBackPressed(context);
    }
  }

  Future<void> _takePhoto(String slot) async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        _capturedPhotos[slot] = File(picked.path);
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _damageNotesController.dispose();
    _odometerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        _previousPage();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorScheme.surface,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
            onPressed: _previousPage,
          ),
          title: Text(
            _currentStep < 2 ? 'Car Inspection' : 'Car Photos',
            style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: Text(
                  '${_currentStep + 1}/3',
                  style: textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildProgressBar(context),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) => setState(() => _currentStep = idx),
                children: [
                  _buildExteriorStep(context),
                  _buildInteriorStep(context),
                  _buildPhotoStep(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.surface,
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= _currentStep ? colorScheme.primary : colorScheme.onSurface.withOpacity(0.1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- STEP 1: EXTERIOR ---
  Widget _buildExteriorStep(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "EXTERIOR CHECK", 
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900, 
              color: colorScheme.onSurface.withOpacity(0.5), 
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildToggleItem(context, Icons.handyman_outlined, "No pre-existing scratches", _noScratches, (v) => setState(() => _noScratches = v)),
          _buildToggleItem(context, Icons.lightbulb_outline, "All lights functional", _lightsWorking, (v) => setState(() => _lightsWorking = v)),
          _buildToggleItem(context, Icons.settings_input_component, "Tyre condition OK", _tyreOk, (v) => setState(() => _tyreOk = v)),
          _buildToggleItem(context, Icons.window, "Windscreen no damage", _windscreenOk, (v) => setState(() => _windscreenOk = v)),
          _buildToggleItem(context, Icons.directions_car, "Body panels intact", _bodyPanelsOk, (v) => setState(() => _bodyPanelsOk = v)),
          const SizedBox(height: 24),
          Text(
            "EXISTING DAMAGE NOTES", 
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900, 
              color: colorScheme.onSurface.withOpacity(0.5), 
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _damageNotesController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "Tap to note any existing damage...",
            ),
          ),
          const SizedBox(height: 40),
          _buildActionButton(context, "Next: Interior Check →", _nextPage),
        ],
      ),
    );
  }

  // --- STEP 2: INTERIOR ---
  Widget _buildInteriorStep(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "INTERIOR CHECK", 
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900, 
              color: colorScheme.onSurface.withOpacity(0.5), 
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          _buildToggleItem(context, Icons.event_seat, "Seats undamaged", _seatsOk, (v) => setState(() => _seatsOk = v)),
          _buildToggleItem(context, Icons.dashboard_customize_outlined, "Dashboard intact", _dashboardOk, (v) => setState(() => _dashboardOk = v)),
          _buildToggleItem(context, Icons.key, "Keys received", _keysReceived, (v) => setState(() => _keysReceived = v)),
          _buildToggleItem(context, Icons.cleaning_services, "No valuables left in car", _noValuables, (v) => setState(() => _noValuables = v)),
          const SizedBox(height: 24),
          Text(
            "ODOMETER READING", 
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900, 
              color: colorScheme.onSurface.withOpacity(0.5), 
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _odometerController,
            style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1, color: colorScheme.primary),
            decoration: InputDecoration(
              fillColor: colorScheme.primary.withOpacity(0.05),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16), 
                borderSide: BorderSide(color: colorScheme.primary.withOpacity(0.2)),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "FUEL LEVEL", 
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w900, 
              color: colorScheme.onSurface.withOpacity(0.5), 
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          _buildFuelSelector(context),
          const SizedBox(height: 40),
          _buildActionButton(context, "Next: Photo Capture →", _nextPage),
        ],
      ),
    );
  }

  // --- STEP 3: PHOTOS ---
  Widget _buildPhotoStep(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Take all required photos before proceeding", 
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _capturedPhotos.length,
            itemBuilder: (context, index) {
              String slot = _capturedPhotos.keys.elementAt(index);
              File? photo = _capturedPhotos[slot];
              return _buildPhotoSlot(context, slot, photo);
            },
          ),
          const SizedBox(height: 24),
          Text(
            "$_photosCount/6 photos taken · Minimum 4 required",
            style: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold, color: colorScheme.onSurface.withOpacity(0.8)),
          ),
          const SizedBox(height: 40),
          _buildActionButton(
            context,
            "Next: Customer Handover →", 
            _nextPage, 
            enabled: _photosCount >= 4,
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---
  Widget _buildToggleItem(BuildContext context, IconData icon, String label, bool value, Function(bool) onChanged) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: colorScheme.onSurface.withOpacity(0.3)),
        title: Text(label, style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
        value: value,
        activeThumbColor: AppColors.success,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFuelSelector(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ["E", "1/4", "1/2", "3/4", "F"].map((e) => Text(e, style: textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold))).toList(),
          ),
          Slider(
            value: _fuelLevel,
            activeColor: colorScheme.primary,
            onChanged: (v) => setState(() => _fuelLevel = v),
          ),
          Text(
            "~${(_fuelLevel * 100).toInt()}% Full", 
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSlot(BuildContext context, String slot, File? photo) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    bool hasPhoto = photo != null;
    return GestureDetector(
      onTap: () => _takePhoto(slot),
      child: Container(
        decoration: BoxDecoration(
          color: hasPhoto ? AppColors.success.withOpacity(0.1) : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasPhoto ? AppColors.success : colorScheme.outlineVariant,
            width: hasPhoto ? 2 : 1,
          ),
          image: hasPhoto ? DecorationImage(image: FileImage(photo), fit: BoxFit.cover, opacity: 0.3) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  hasPhoto ? Icons.check_circle : Icons.camera_alt, 
                  color: hasPhoto ? AppColors.success : colorScheme.onSurface.withOpacity(0.2), 
                  size: 32,
                ),
                const SizedBox(height: 4),
                Text(
                  slot, 
                  style: textTheme.labelLarge?.copyWith(
                    color: hasPhoto ? AppColors.success : colorScheme.onSurface.withOpacity(0.4), 
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (hasPhoto)
              Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle, color: AppColors.success, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(BuildContext context, String label, VoidCallback onPressed, {bool enabled = true}) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.designYellow,
          foregroundColor: Colors.black,
        ),
        child: Text(label),
      ),
    );
  }
}
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

  void _previousPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _previousPage();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.black,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: _previousPage,
          ),
          title: Text(
            _currentStep < 2 ? 'Car Inspection' : 'Car Photos',
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                child: Text(
                  '${_currentStep + 1}/3',
                  style: const TextStyle(color: Colors.white54, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (idx) => setState(() => _currentStep = idx),
                children: [
                  _buildExteriorStep(),
                  _buildInteriorStep(),
                  _buildPhotoStep(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
      child: Row(
        children: List.generate(3, (index) {
          return Expanded(
            child: Container(
              height: 4,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: index <= _currentStep ? AppColors.designForestGreen : Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // --- STEP 1: EXTERIOR ---
  Widget _buildExteriorStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("EXTERIOR CHECK", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey, fontSize: 13, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _buildToggleItem(Icons.handyman_outlined, "No pre-existing scratches", _noScratches, (v) => setState(() => _noScratches = v)),
          _buildToggleItem(Icons.lightbulb_outline, "All lights functional", _lightsWorking, (v) => setState(() => _lightsWorking = v)),
          _buildToggleItem(Icons.settings_input_component, "Tyre condition OK", _tyreOk, (v) => setState(() => _tyreOk = v)),
          _buildToggleItem(Icons.window, "Windscreen no damage", _windscreenOk, (v) => setState(() => _windscreenOk = v)),
          _buildToggleItem(Icons.directions_car, "Body panels intact", _bodyPanelsOk, (v) => setState(() => _bodyPanelsOk = v)),
          const SizedBox(height: 24),
          const Text("EXISTING DAMAGE NOTES", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey, fontSize: 13, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          TextField(
            controller: _damageNotesController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Tap to note any existing damage...",
              fillColor: AppColors.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 40),
          _buildActionButton("Next: Interior Check →", _nextPage),
        ],
      ),
    );
  }

  // --- STEP 2: INTERIOR ---
  Widget _buildInteriorStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("INTERIOR CHECK", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey, fontSize: 13, letterSpacing: 1.2)),
          const SizedBox(height: 16),
          _buildToggleItem(Icons.event_seat, "Seats undamaged", _seatsOk, (v) => setState(() => _seatsOk = v)),
          _buildToggleItem(Icons.dashboard_customize_outlined, "Dashboard intact", _dashboardOk, (v) => setState(() => _dashboardOk = v)),
          _buildToggleItem(Icons.key, "Keys received", _keysReceived, (v) => setState(() => _keysReceived = v)),
          _buildToggleItem(Icons.cleaning_services, "No valuables left in car", _noValuables, (v) => setState(() => _noValuables = v)),
          const SizedBox(height: 24),
          const Text("ODOMETER READING", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey, fontSize: 13, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          TextField(
            controller: _odometerController,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1, color: Colors.indigo),
            decoration: InputDecoration(
              fillColor: AppColors.designMint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.designForestGreen, width: 2)),
            ),
          ),
          const SizedBox(height: 24),
          const Text("FUEL LEVEL", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey, fontSize: 13, letterSpacing: 1.2)),
          const SizedBox(height: 12),
          _buildFuelSelector(),
          const SizedBox(height: 40),
          _buildActionButton("Next: Photo Capture →", _nextPage),
        ],
      ),
    );
  }

  // --- STEP 3: PHOTOS ---
  Widget _buildPhotoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Take all required photos before proceeding", style: TextStyle(color: Colors.blueGrey, fontSize: 15)),
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
              return _buildPhotoSlot(slot, photo);
            },
          ),
          const SizedBox(height: 24),
          Text(
            "$_photosCount/6 photos taken · Minimum 4 required",
            style: const TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 40),
          _buildActionButton(
            "Next: Customer Handover →", 
            _nextPage, 
            enabled: _photosCount >= 4,
          ),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---
  Widget _buildToggleItem(IconData icon, String label, bool value, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: Colors.blueGrey.shade300),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
        value: value,
        activeColor: AppColors.designForestGreen,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildFuelSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.designMint.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const ["E", "1/4", "1/2", "3/4", "F"].map((e) => Text(e, style: const TextStyle(fontWeight: FontWeight.bold))).toList(),
          ),
          Slider(
            value: _fuelLevel,
            activeColor: AppColors.designForestGreen,
            onChanged: (v) => setState(() => _fuelLevel = v),
          ),
          Text("~${(_fuelLevel * 100).toInt()}% Full", style: const TextStyle(color: AppColors.designForestGreen, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPhotoSlot(String slot, File? photo) {
    bool hasPhoto = photo != null;
    return GestureDetector(
      onTap: () => _takePhoto(slot),
      child: Container(
        decoration: BoxDecoration(
          color: hasPhoto ? const Color(0xFFE8F5E9) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasPhoto ? AppColors.designForestGreen : Colors.black12,
            style: hasPhoto ? BorderStyle.solid : BorderStyle.none,
          ),
          image: hasPhoto ? DecorationImage(image: FileImage(photo), fit: BoxFit.cover, opacity: 0.3) : null,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(hasPhoto ? Icons.check_circle : Icons.camera_alt, color: hasPhoto ? AppColors.designForestGreen : Colors.blueGrey.shade200, size: 32),
                const SizedBox(height: 4),
                Text(slot, style: TextStyle(color: hasPhoto ? AppColors.designForestGreen : Colors.blueGrey.shade400, fontWeight: FontWeight.bold)),
              ],
            ),
            if (hasPhoto)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(Icons.check_circle, color: AppColors.designForestGreen, size: 20),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed, {bool enabled = true}) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.designYellow,
          foregroundColor: Colors.black,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        onPressed: enabled ? onPressed : null,
        child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      ),
    );
  }
}
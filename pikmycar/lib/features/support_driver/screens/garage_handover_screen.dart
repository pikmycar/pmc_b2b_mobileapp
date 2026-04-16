import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GarageHandoverScreen extends StatefulWidget {
  const GarageHandoverScreen({Key? key}) : super(key: key);

  @override
  State<GarageHandoverScreen> createState() => _GarageHandoverScreenState();
}

class _GarageHandoverScreenState extends State<GarageHandoverScreen> {
  // Checklist State
  bool _isCarDelivered = false;
  bool _areKeysHanded = false;
  bool _isParkingNoted = true; // Default to true as often done
  bool _isReceiptReceived = false;

  final TextEditingController _techNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  bool get _canSubmit => _isCarDelivered && _areKeysHanded;

  @override
  void dispose() {
    _techNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submitHandover() {
    // Show a quick success snackbar before returning home
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Handover Submitted Successfully! Ride Completed."),
        backgroundColor: AppColors.designForestGreen,
      ),
    );
    
    // Navigate to Ride Summary
    Navigator.pushReplacementNamed(context, '/support_driver_ride_summary');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.designForestGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Garage Handover',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTopProgressBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card 1: Arrival Confirmation
                  _buildArrivalCard(),
                  const SizedBox(height: 24),

                  // Card 2: Handover Checklist
                  _buildChecklistCard(),
                  const SizedBox(height: 24),

                  // Form Section: Tech & Notes
                  const Text("TECHNICIAN DETAILS", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey, fontSize: 13, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  _buildTextField(_techNameController, "Technician Name (Optional)", Icons.person_outline),
                  
                  const SizedBox(height: 24),
                  const Text("ADDITIONAL NOTES", style: TextStyle(fontWeight: FontWeight.w900, color: Colors.blueGrey, fontSize: 13, letterSpacing: 1.2)),
                  const SizedBox(height: 12),
                  _buildTextField(_notesController, "Special instructions or parking details...", Icons.notes, isMultiline: true),
                  
                  const SizedBox(height: 40),

                  // Final Action Button
                  SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _canSubmit ? _submitHandover : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.designForestGreen,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Close Ride & Submit",
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopProgressBar() {
    return Container(
      color: AppColors.designForestGreen,
      padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Text("Step 3/3", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12)),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Expanded(child: Container(decoration: BoxDecoration(color: AppColors.designYellow, borderRadius: BorderRadius.circular(2)))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.designMint.withOpacity(0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.designForestGreen.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.designForestGreen, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text("Arrived at Garage!", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.designForestGreen)),
                Text("Al Quoz Auto Service Center", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("Dubai Marina Industrial Area", style: TextStyle(color: Colors.blueGrey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("HANDOVER CHECKLIST", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1.2)),
          const SizedBox(height: 20),
          _buildToggleItem("Car delivered to garage team", _isCarDelivered, (v) => setState(() => _isCarDelivered = v), isRequired: true),
          _buildToggleItem("Keys handed to technician", _areKeysHanded, (v) => setState(() => _areKeysHanded = v), isRequired: true),
          _buildToggleItem("Parking location noted", _isParkingNoted, (v) => setState(() => _isParkingNoted = v)),
          _buildToggleItem("Garage receipt received", _isReceiptReceived, (v) => setState(() => _isReceiptReceived = v)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(String label, bool value, Function(bool) onChanged, {bool isRequired = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
            if (isRequired) const Padding(
              padding: EdgeInsets.only(left: 4.0),
              child: Text("*", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        value: value,
        activeColor: AppColors.designForestGreen,
        onChanged: onChanged,
        dense: true,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, {bool isMultiline = false}) {
    return TextField(
      controller: controller,
      maxLines: isMultiline ? 4 : 1,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blueGrey.shade300),
        fillColor: AppColors.background,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }
}

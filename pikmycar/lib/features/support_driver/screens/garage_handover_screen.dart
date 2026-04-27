import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class GarageHandoverScreen extends StatefulWidget {
  const GarageHandoverScreen({super.key});

  @override
  State<GarageHandoverScreen> createState() => _GarageHandoverScreenState();
}

class _GarageHandoverScreenState extends State<GarageHandoverScreen> {
  // Checklist State
  bool _isCarDelivered = false;
  bool _areKeysHanded = false;
  bool _isParkingNoted = false; 
  bool _isReceiptReceived = false;

  final TextEditingController _techNameController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // Updated Validation: Require ALL 4 checklist items to be checked
  bool get _canSubmit => 
      _isCarDelivered && 
      _areKeysHanded && 
      _isParkingNoted && 
      _isReceiptReceived;

  @override
  void dispose() {
    _techNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

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

  void _submitHandover() {
    // Capture the dispatcher and context-dependent data before navigation
    final messenger = ScaffoldMessenger.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    messenger.showSnackBar(
      SnackBar(
        content: const Text("Handover Submitted Successfully! Ride Completed."),
        backgroundColor: colorScheme.secondary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/support_driver_ride_summary');
    }
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
        await _onBackPressed(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: colorScheme.primary,
          iconTheme: IconThemeData(color: colorScheme.onPrimary),
          title: Text(
            'Garage Handover',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onPrimary, 
              fontWeight: FontWeight.w900,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Column(
          children: [
            _buildTopProgressBar(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card 1: Arrival Confirmation
                    _buildArrivalCard(context),
                    const SizedBox(height: 24),

                    // Card 2: Handover Checklist
                    _buildChecklistCard(context),
                    const SizedBox(height: 24),

                    // Form Section: Tech & Notes
                    Text(
                      "TECHNICIAN DETAILS", 
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900, 
                        color: colorScheme.onSurface.withOpacity(0.5), 
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(context, _techNameController, "Technician Name (Optional)", Icons.person_outline),
                    
                    const SizedBox(height: 24),
                    Text(
                      "ADDITIONAL NOTES", 
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900, 
                        color: colorScheme.onSurface.withOpacity(0.5), 
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(context, _notesController, "Special instructions or parking details...", Icons.notes, isMultiline: true),
                    
                    const SizedBox(height: 40),

                    // Final Action Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _canSubmit ? _submitHandover : null,
                        child: const Text("Close Ride & Submit"),
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!_canSubmit)
                      Center(
                        child: Text(
                          "Please complete the checklist to proceed",
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.error.withOpacity(0.7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopProgressBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      color: colorScheme.primary,
      padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            "Step 3/3", 
            style: textTheme.labelSmall?.copyWith(
              color: colorScheme.onPrimary.withOpacity(0.7), 
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: colorScheme.secondary, 
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.secondary.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: colorScheme.secondary, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Arrived at Garage!", 
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900, 
                    color: colorScheme.secondary,
                  ),
                ),
                Text(
                  "Al Quoz Auto Service Center", 
                  style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  "Dubai Marina Industrial Area", 
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "HANDOVER CHECKLIST", 
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold, 
              color: colorScheme.onSurface.withOpacity(0.5), 
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          _buildToggleItem(context, "Car delivered to garage team", _isCarDelivered, (v) => setState(() => _isCarDelivered = v)),
          _buildToggleItem(context, "Keys handed to technician", _areKeysHanded, (v) => setState(() => _areKeysHanded = v)),
          _buildToggleItem(context, "Parking location noted", _isParkingNoted, (v) => setState(() => _isParkingNoted = v)),
          _buildToggleItem(context, "Garage receipt received", _isReceiptReceived, (v) => setState(() => _isReceiptReceived = v)),
        ],
      ),
    );
  }

  Widget _buildToggleItem(BuildContext context, String label, bool value, Function(bool) onChanged) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Row(
          children: [
            Expanded(
              child: Text(label, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text("*", style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        value: value,
        activeThumbColor: colorScheme.secondary,
        onChanged: onChanged,
        dense: true,
      ),
    );
  }

  Widget _buildTextField(BuildContext context, TextEditingController controller, String hint, IconData icon, {bool isMultiline = false}) {
    return TextField(
      controller: controller,
      maxLines: isMultiline ? 4 : 1,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
      ),
    );
  }
}

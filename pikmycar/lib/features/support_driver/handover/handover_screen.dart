import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../../core/theme/app_theme.dart';

class HandoverScreen extends StatefulWidget {
  const HandoverScreen({super.key});

  @override
  State<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends State<HandoverScreen> {
  late final SignatureController _signatureController;

  // Toggle States
  bool _informed = true;
  bool _keysReceived = true;
  bool _inspectionShared = true;
  bool _valuablesRemoved = false;

  bool get _isSignatureProvided => _signatureController.isNotEmpty;
  bool get _canConfirm =>
      _informed && _keysReceived && _inspectionShared && _isSignatureProvided;

  @override
  void initState() {
    super.initState();
    _signatureController = SignatureController(
      penColor: Colors.black, // Signature pad usually black ink, or we could theme it
      penStrokeWidth: 3,
    );
    _signatureController.onDrawStart = () {
      setState(() {}); // Update to hide placeholder
    };
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        iconTheme: IconThemeData(color: colorScheme.onPrimary),
        title: Text(
          'Handover',
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.w900,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
        child: Column(
          children: [
            // Customer Confirmation Card
            _buildCustomerCard(context),
            const SizedBox(height: 24),

            // Signature Card
            _buildSignatureCard(context),
            const SizedBox(height: 32),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canConfirm
                    ? () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/support_driver_drive_to_garage',
                        );
                      }
                    : null,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check, size: 24),
                    SizedBox(width: 12),
                    Text("Confirm & Start Drive to Garage"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "By confirming you acknowledge the car condition report",
              style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context) {
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
            "CUSTOMER CONFIRMATION",
            style: textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface.withOpacity(0.5),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: AppColors.designYellow,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    "AA",
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20, color: Colors.black),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Ahmed Al-Rashid",
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      "BMW 3 Series · M72528",
                      style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.6)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildHandoverToggle(
            context,
            "Customer informed of service",
            _informed,
            (v) => setState(() => _informed = v),
          ),
          _buildHandoverToggle(
            context,
            "Keys received",
            _keysReceived,
            (v) => setState(() => _keysReceived = v),
          ),
          _buildHandoverToggle(
            context,
            "Inspection completed together",
            _inspectionShared,
            (v) => setState(() => _inspectionShared = v),
          ),
          _buildHandoverToggle(
            context,
            "Valuables removed from car",
            _valuablesRemoved,
            (v) => setState(() => _valuablesRemoved = v),
          ),
        ],
      ),
    );
  }

  Widget _buildHandoverToggle(
    BuildContext context,
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colorScheme.onSurface.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SwitchListTile(
        title: Text(
          label,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        value: value,
        activeColor: AppColors.success,
        onChanged: onChanged,
        dense: true,
      ),
    );
  }

  Widget _buildSignatureCard(BuildContext context) {
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "CUSTOMER SIGNATURE",
                style: textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface.withOpacity(0.5),
                  letterSpacing: 1.2,
                ),
              ),
              if (_isSignatureProvided)
                TextButton.icon(
                  onPressed: () => setState(() => _signatureController.clear()),
                  icon: Icon(Icons.clear, size: 16, color: colorScheme.error),
                  label: Text(
                    "Clear",
                    style: textTheme.labelSmall?.copyWith(color: colorScheme.error, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: colorScheme.onSurface.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Stack(
              children: [
                Signature(
                  controller: _signatureController,
                  height: 180,
                  backgroundColor: Colors.transparent,
                ),
                if (!_isSignatureProvided)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("✍️", style: TextStyle(fontSize: 24)),
                        const SizedBox(height: 8),
                        Text(
                          "Tap to sign here",
                          style: textTheme.labelLarge?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.3),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Customer signature confirms handover and inspection agreement",
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

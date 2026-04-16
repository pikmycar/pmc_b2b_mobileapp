import 'package:flutter/material.dart';
import 'package:signature/signature.dart';
import '../../../core/theme/app_theme.dart';

class HandoverScreen extends StatefulWidget {
  const HandoverScreen({Key? key}) : super(key: key);

  @override
  State<HandoverScreen> createState() => _HandoverScreenState();
}

class _HandoverScreenState extends State<HandoverScreen> {
  final SignatureController _signatureController = SignatureController(
    penColor: Colors.black,
    penStrokeWidth: 3,
  );

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.designForestGreen,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Handover',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            fontSize: 24,
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
            _buildCustomerCard(),
            const SizedBox(height: 24),

            // Signature Card
            _buildSignatureCard(),
            const SizedBox(height: 32),

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 64,
              child: ElevatedButton(
                onPressed:
                    _canConfirm
                        ? () {
                          Navigator.pushReplacementNamed(
                            context,
                            '/support_driver_drive_to_garage',
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.designForestGreen,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade300,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check, size: 24),
                    SizedBox(width: 12),
                    Text(
                      "Confirm & Start Drive to Garage",
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "By confirming you acknowledge the car condition report",
              style: TextStyle(color: Colors.blueGrey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "CUSTOMER CONFIRMATION",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
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
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Ahmed Al-Rashid",
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    "BMW 3 Series · M72528",
                    style: TextStyle(color: Colors.blueGrey, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildHandoverToggle(
            "Customer informed of service",
            _informed,
            (v) => setState(() => _informed = v),
          ),
          _buildHandoverToggle(
            "Keys received",
            _keysReceived,
            (v) => setState(() => _keysReceived = v),
          ),
          _buildHandoverToggle(
            "Inspection completed together",
            _inspectionShared,
            (v) => setState(() => _inspectionShared = v),
          ),
          _buildHandoverToggle(
            "Valuables removed from car",
            _valuablesRemoved,
            (v) => setState(() => _valuablesRemoved = v),
          ),
        ],
      ),
    );
  }

  Widget _buildHandoverToggle(
    String label,
    bool value,
    Function(bool) onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: SwitchListTile(
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        value: value,
        activeColor: AppColors.designForestGreen,
        onChanged: onChanged,
        dense: true,
      ),
    );
  }

  Widget _buildSignatureCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black12, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "CUSTOMER SIGNATURE",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                  letterSpacing: 1.2,
                ),
              ),
              if (_isSignatureProvided)
                TextButton.icon(
                  onPressed: () => setState(() => _signatureController.clear()),
                  icon: const Icon(Icons.clear, size: 16, color: Colors.red),
                  label: const Text(
                    "Clear",
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.black12,
                style: BorderStyle.none,
              ), // Mockup has dashed but signature widget is cleaner
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
                      children: const [
                        Text("✍️", style: TextStyle(fontSize: 24)),
                        SizedBox(height: 8),
                        Text(
                          "Tap to sign here",
                          style: TextStyle(
                            color: Colors.blueGrey,
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
          const Text(
            "Customer signature confirms handover and inspection agreement",
            style: TextStyle(color: Colors.blueGrey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

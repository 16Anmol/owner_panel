import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'success_screen.dart';

class SelfVerificationScreen extends StatefulWidget {
  const SelfVerificationScreen({super.key});

  @override
  State<SelfVerificationScreen> createState() => _SelfVerificationScreenState();
}

class _SelfVerificationScreenState extends State<SelfVerificationScreen> {
  bool _frontUploaded = false;
  bool _backUploaded = false;
  bool _isSubmitting = false;

  void _simulateUpload(String side) async {
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      if (side == 'front') _frontUploaded = true;
      if (side == 'back') _backUploaded = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aadhaar $side side uploaded!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_frontUploaded || !_backUploaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload both front and back of Aadhaar'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isSubmitting = false);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const SuccessScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.textDark),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text(
                    'Self Verification',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 10),

                    // Shield Icon Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.success.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.verified_user_rounded,
                              color: AppColors.success, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Aadhaar Card Verification',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.success,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Upload both sides of your Aadhaar',
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Front Side
                    const FieldLabel('Front Side'),
                    const SizedBox(height: 8),
                    UploadBox(
                      label: _frontUploaded ? 'Front Uploaded ✓' : 'Front',
                      uploaded: _frontUploaded,
                      onTap: () => _simulateUpload('front'),
                    ),
                    const SizedBox(height: 20),

                    // Back Side
                    const FieldLabel('Back Side'),
                    const SizedBox(height: 8),
                    UploadBox(
                      label: _backUploaded ? 'Back Uploaded ✓' : 'Back',
                      uploaded: _backUploaded,
                      onTap: () => _simulateUpload('back'),
                    ),
                    const SizedBox(height: 20),

                    // Privacy note
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.lock_outline_rounded,
                              size: 18, color: AppColors.textMuted),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your documents are encrypted and stored securely. We never share your personal information with third parties.',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                  height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: PrimaryButton(
                label: 'Submit',
                isLoading: _isSubmitting,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

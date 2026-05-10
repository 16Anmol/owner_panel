import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';
import 'self_verification_screen.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({super.key});

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  bool _registryUploaded = false;
  bool _nocUploaded = false;

  void _simulateUpload(String docType) async {
    // In real app: use file_picker package
    await Future.delayed(const Duration(milliseconds: 400));
    setState(() {
      if (docType == 'registry') _registryUploaded = true;
      if (docType == 'noc') _nocUploaded = true;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$docType document uploaded successfully!'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
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
                    'Property Verification',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Header info box
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.primary),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.info_outline_rounded,
                              color: AppColors.primary, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Upload Property Documents For Verification',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Registry Documents
                    const FieldLabel('Upload Registry Documents'),
                    const SizedBox(height: 8),
                    UploadBox(
                      label: _registryUploaded
                          ? 'Registry Uploaded ✓'
                          : 'Tap to Upload Registry',
                      uploaded: _registryUploaded,
                      onTap: () => _simulateUpload('registry'),
                    ),
                    const SizedBox(height: 24),

                    // NOC Documents
                    const FieldLabel('Upload NOC Documents'),
                    const SizedBox(height: 8),
                    UploadBox(
                      label:
                          _nocUploaded ? 'NOC Uploaded ✓' : 'Tap to Upload NOC',
                      uploaded: _nocUploaded,
                      onTap: () => _simulateUpload('noc'),
                    ),
                    const SizedBox(height: 28),

                    // Tips
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F7FF),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFBDD6F5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Tips for uploading',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1565C0),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '• Use clear, well-lit photos\n• Ensure all text is readable\n• File size must be under 5MB\n• Supported: JPG, PNG, PDF',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF1565C0),
                              height: 1.6,
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SelfVerificationScreen()),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

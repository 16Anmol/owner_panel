import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class UploadPropertyScreen extends StatelessWidget {
  const UploadPropertyScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Upload Property',
              style: TextStyle(
                  fontWeight: FontWeight.w800, color: AppColors.textDark)),
          backgroundColor: AppColors.background,
          elevation: 0,
          leading: const BackButton(color: AppColors.textDark),
        ),
        body: const Center(
            child: Text('Upload property form coming soon',
                style: TextStyle(color: AppColors.textMuted))),
      );
}

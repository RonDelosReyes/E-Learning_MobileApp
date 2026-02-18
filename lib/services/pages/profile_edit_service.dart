import 'dart:io';
import 'package:e_learning_app/services/pages/profile_service.dart';
import 'package:e_learning_app/services/pages/profile_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../user_provider.dart';

class ProfileAvatarUploader extends StatefulWidget {
  final int userId;
  final double radius;

  const ProfileAvatarUploader({
    super.key,
    required this.userId,
    this.radius = 50,
  });

  @override
  State<ProfileAvatarUploader> createState() => _ProfileAvatarUploaderState();
}

class _ProfileAvatarUploaderState extends State<ProfileAvatarUploader> {
  final ProfileStorageService _storageService = ProfileStorageService();
  bool _isUploading = false;
  bool _isPickingImage = false;

  /// Pick image from gallery and upload
  Future<void> _pickAndUploadImage() async {
    if (_isPickingImage || _isUploading) return;
    _isPickingImage = true;

    final picker = ImagePicker();

    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final file = File(picked.path);
      setState(() => _isUploading = true);

      final profileService = ProfileService();

      // 1️⃣ Fetch old profile filename from the database
      final oldProfile = await profileService.fetchProfileFile(userId: widget.userId);
      final oldFileName = oldProfile?.filePath;

      // 2️⃣ Upload new image
      final newFileName = await _storageService.uploadProfileImage(
        userId: widget.userId,
        file: file,
        oldFilePath: oldFileName, // automatically deletes old image
      );

      if (newFileName != null) {
        // 3️⃣ Update the database with new file path
        await profileService.updateProfileFilePath(
          userId: widget.userId,
          filePath: newFileName,
        );

        // 4️⃣ Get public URL for the new image
        final publicUrl = _storageService.getPublicUrl(newFileName);

        // 5️⃣ Update Provider with new image
        context.read<UserProvider>().setProfileImage(publicUrl);
      } else {
        debugPrint("Failed to upload profile image");
      }
    } catch (e) {
      debugPrint("Upload Error: $e");
    } finally {
      setState(() {
        _isUploading = false;
        _isPickingImage = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileUrl = context.watch<UserProvider>().profileImagePath;

    final ImageProvider imageProvider;
    if (profileUrl.isEmpty) {
      imageProvider = const AssetImage('assets/profile_pic.png');
    } else if (profileUrl.startsWith('http')) {
      imageProvider = NetworkImage(profileUrl);
    } else {
      imageProvider = const AssetImage('assets/profile_pic.png');
    }

    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        GestureDetector(
          onTap: _isUploading ? null : _pickAndUploadImage,
          child: CircleAvatar(
            radius: widget.radius,
            backgroundColor: const Color(0xFFE3F2FD),
            backgroundImage: imageProvider,
            child: _isUploading
                ? const CircularProgressIndicator(color: Colors.white)
                : null,
          ),
        ),
        Positioned(
          bottom: 4,
          right: 4,
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              color: Color(0xFF33A1E0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.camera_alt, size: 18, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../back_end/services/profile/profile_service.dart';
import '../../../back_end/utils/profile_storage_service.dart';
import '../../../back_end/providers/user_provider.dart';
import 'profile_pic_editor.dart';

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

  Future<void> _pickAndUploadImage() async {
    if (_isPickingImage || _isUploading) return;
    _isPickingImage = true;

    final picker = ImagePicker();

    try {
      final picked = await picker.pickImage(source: ImageSource.gallery);
      if (picked == null) return;

      final file = File(picked.path);

      if (!mounted) return;

      // Show the editor
      await showGeneralDialog(
        context: context,
        barrierDismissible: false,
        pageBuilder: (context, _, __) {
          return ProfilePicEditor(
            imageFile: file,
            onCancel: () => Navigator.pop(context),
            onSave: (croppedFile) async {
              Navigator.pop(context); // Close editor
              await _processAndUpload(croppedFile);
            },
          );
        },
      );
    } catch (e) {
      debugPrint("Picker Error: $e");
      _showSimpleError("Failed to select image.");
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  Future<void> _processAndUpload(File file) async {
    setState(() => _isUploading = true);
    try {
      final profileService = ProfileService();

      // 1️⃣ Fetch old profile filename
      final oldProfile = await profileService.fetchProfileFile(userId: widget.userId);
      final oldFileName = oldProfile?.filePath;

      // 2️⃣ Upload new image (the CROPPED one)
      final newFileName = await _storageService.uploadProfileImage(
        userId: widget.userId,
        file: file,
        oldFilePath: oldFileName,
      );

      if (newFileName != null) {
        // 3️⃣ Update the database
        await profileService.updateProfileFilePath(
          userId: widget.userId,
          filePath: newFileName,
        );

        // 4️⃣ Refresh Provider
        if (mounted) {
          await context.read<UserProvider>().refreshProfileImage();
        }
      } else {
        _showSimpleError("Failed to upload image. Please try again.");
      }
    } catch (e) {
      debugPrint("Upload Error: $e");
      _showSimpleError("Something went wrong while updating your profile picture.");
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  void _showSimpleError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileUrl = context.watch<UserProvider>().profileImagePath;

    final ImageProvider imageProvider;
    if (profileUrl.isEmpty || profileUrl == 'assets/profile_pic.png') {
      imageProvider = const AssetImage('assets/profile_pic.png');
    } else if (profileUrl.startsWith('http')) {
      imageProvider = NetworkImage(profileUrl);
    } else if (profileUrl.startsWith('assets/')) {
      imageProvider = AssetImage(profileUrl);
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

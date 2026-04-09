import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePicEditor extends StatefulWidget {
  final File imageFile;
  final VoidCallback onCancel;
  final Function(File croppedFile) onSave;

  const ProfilePicEditor({
    super.key,
    required this.imageFile,
    required this.onCancel,
    required this.onSave,
  });

  @override
  State<ProfilePicEditor> createState() => _ProfilePicEditorState();
}

class _ProfilePicEditorState extends State<ProfilePicEditor> {
  Offset _position = Offset.zero;
  double _scale = 1.0;
  double _previousScale = 1.0;
  final GlobalKey _cropKey = GlobalKey();
  bool _isProcessing = false;

  Future<void> _handleSave() async {
    setState(() => _isProcessing = true);
    try {
      // Capture the transformed image within the circle
      RenderRepaintBoundary? boundary = 
          _cropKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      
      if (boundary == null) return;

      // We use a high pixel ratio for better quality
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      if (byteData == null) return;

      final uint8List = byteData.buffer.asUint8List();

      // Save to a temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/cropped_profile_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(uint8List);

      widget.onSave(file);
    } catch (e) {
      debugPrint("Crop Error: $e");
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size.width * 0.85;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              "Adjust Profile Picture",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Drag to move • Pinch to zoom",
              style: TextStyle(
                color: Colors.white60,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
            const Spacer(),
            // Editor Area
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // RepaintBoundary only wraps what we want to capture
                  RepaintBoundary(
                    key: _cropKey,
                    child: Container(
                      width: size,
                      height: size,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black, // Dark background for the crop area
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: GestureDetector(
                        onScaleStart: (details) {
                          if (_isProcessing) return;
                          _previousScale = _scale;
                        },
                        onScaleUpdate: (details) {
                          if (_isProcessing) return;
                          setState(() {
                            _scale = (_previousScale * details.scale).clamp(0.1, 5.0);
                            _position += details.focalPointDelta;
                          });
                        },
                        child: Transform(
                          transform: Matrix4.identity()
                            ..translate(_position.dx, _position.dy)
                            ..scale(_scale),
                          alignment: Alignment.center,
                          child: Image.file(
                            widget.imageFile,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Visual Guide Overlay (NOT inside RepaintBoundary so it's not captured)
                  IgnorePointer(
                    child: Container(
                      width: size,
                      height: size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: theme.colorScheme.primary, width: 2.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Action Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _isProcessing ? null : widget.onCancel,
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _isProcessing ? null : _handleSave,
                      child: _isProcessing 
                        ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text(
                            "Save",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

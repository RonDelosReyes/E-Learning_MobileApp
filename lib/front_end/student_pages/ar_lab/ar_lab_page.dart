import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';
import 'package:provider/provider.dart';
import '../../../back_end/providers/user_provider.dart';
import '../../../back_end/services/pages/student/ar_lab/ar_lab_service.dart';
import '../../../back_end/utils/hardware_checker.dart';
import '../../widgets/dialog/ar_compatibility_dialog.dart';
import '../../widgets/dialog/ar_install_dialog.dart';
import '../../widgets/hamburgMenu.dart';

class ARLabPage extends StatefulWidget {
  const ARLabPage({super.key});

  @override
  State<ARLabPage> createState() => _ARLabPageState();
}

class _ARLabPageState extends State<ARLabPage> {
  static const String _activityName = "First AR Activity";
  final ArLabService _arLabService = ArLabService();
  UnityWidgetController? _unityWidgetController;

  bool _isUnityReady = false;
  bool _isCheckingCompatibility = true;
  ArSupportStatus _supportStatus = ArSupportStatus.supported;

  @override
  void initState() {
    super.initState();
    _checkCompatibility();
  }

  Future<void> _checkCompatibility() async {
    final status = await HardwareChecker.checkArSupportStatus();
    if (mounted) {
      setState(() {
        _supportStatus = status;
        _isCheckingCompatibility = false;
      });

      if (status == ArSupportStatus.unsupported) {
        ArCompatibilityDialog.show(context);
      } else if (status == ArSupportStatus.needsInstall) {
        ArInstallDialog.show(context);
      }
    }
  }

  @override
  void dispose() {
    _unityWidgetController?.dispose();
    super.dispose();
  }

  // Callback that connects the controller
  void onUnityCreated(controller) {
    _unityWidgetController = controller;
    setState(() {
      _isUnityReady = true;
    });
  }

  // Communication from Unity to Flutter
  void onUnityMessage(message) {
    debugPrint('Received message from Unity: ${message.toString()}');
    try {
      final Map<String, dynamic> data = json.decode(message.toString());

      // 'isFinished' from Unity triggers the DB save
      final bool isSessionEnded =
          data['isFinished'] ?? data['isCompleted'] ?? false;

      // Only record performance in DB AFTER the session is finished
      if (isSessionEnded) {
        final int score = data['score'] ?? 0;
        final bool isNewHighscore = data['isNewHighscore'] ?? false;

        if (isNewHighscore) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  "New Highscore Reached!",
                  style: TextStyle(fontFamily: 'Poppins'),
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }

        final userProvider = Provider.of<UserProvider>(context, listen: false);

        if (userProvider.userId != null) {
          _arLabService.recordArPerformance(
            userId: userProvider.userId!,
            activityName: _activityName,
            accuracyScore: score,
            isCompleted: true,
            errorCount: data['errors'] ?? 0,
            timeSpentSeconds: data['time'] ?? 0,
          );
        }
      }
    } catch (e) {
      debugPrint('Error parsing Unity message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // Allow leaving AR lab
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          // Sync with dashboard or other providers if needed
          // Provider.of<UserProvider>(context, listen: false).refreshSomeData();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black, // Typical for AR backgrounds
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'AR Lab',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: const Color(0xFF33A1E0),
        ),
        drawer: const AppDrawer(currentRoute: 'arlab'),
        body: _isCheckingCompatibility
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : _supportStatus != ArSupportStatus.supported
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _supportStatus == ArSupportStatus.unsupported
                              ? Icons.warning_amber_rounded
                              : Icons.download_rounded,
                          color: Colors.orange,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _supportStatus == ArSupportStatus.unsupported
                              ? 'Hardware Not Compatible'
                              : 'AR Services Missing',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontFamily: 'Poppins'),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            _supportStatus == ArSupportStatus.unsupported
                                ? 'Your device does not support ARCore features required for this lab.'
                                : 'You need to install Google Play Services for AR to continue.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        if (_supportStatus == ArSupportStatus.needsInstall)
                          ElevatedButton(
                            onPressed: () => ArInstallDialog.show(context),
                            child: const Text('Download Now'),
                          ),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey),
                          child: const Text('Go Back'),
                        ),
                      ],
                    ),
                  )
                : Stack(
                    children: [
                      UnityWidget(
                        onUnityCreated: onUnityCreated,
                        onUnityMessage: onUnityMessage,
                        useAndroidViewSurface: true,
                        fullscreen: false,
                      ),
                      if (!_isUnityReady)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                    ],
                  ),
      ),
    );
  }
}

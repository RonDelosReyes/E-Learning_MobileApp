import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:file_picker/file_picker.dart';

/// Downloads a file to app-specific storage
Future<void> downloadFile(String url, String fileName, BuildContext context) async {
  try {
    var status = await Permission.storage.request();
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Storage permission is required to download files.")),
        );
      }
      return;
    }

    Directory downloadsDir;
    if (Platform.isAndroid) {
      downloadsDir = Directory('/storage/emulated/0/Download');
    } else {
      downloadsDir = await getApplicationDocumentsDirectory();
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final filePath = path.join(downloadsDir.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Downloaded to ${file.path}")),
        );
      }
    } else {
      throw Exception("Failed to download file.");
    }
  } catch (e) {
    debugPrint("Download error: $e");
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error downloading file: $e")),
      );
    }
  }
}

/// Downloads a file to a folder selected by the user using SAF
Future<void> downloadFileWithSAF(String url, String fileName, BuildContext context) async {
  try {
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();
    if (selectedDirectory == null) return;

    final safeFileName = fileName.replaceAll(RegExp(r'[\/:*?"<>|]'), '_');

    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) throw Exception("Failed to download file");

    final file = File('$selectedDirectory/$safeFileName');
    await file.writeAsBytes(response.bodyBytes);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Downloaded to $selectedDirectory/$safeFileName")),
    );
  } catch (e) {
    debugPrint("Download error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error downloading file: $e")),
    );
  }
}

/// Request storage permission and create example file
Future<void> requestStoragePermissionAndDownload(BuildContext context) async {
  var status = await Permission.storage.request();

  if (await Permission.photos.isDenied && await Permission.videos.isDenied) {
    await [Permission.photos, Permission.videos, Permission.audio].request();
  }

  if (status.isGranted ||
      await Permission.photos.isGranted ||
      await Permission.videos.isGranted) {
    final dir = await getExternalStorageDirectory();
    if (dir != null) {
      final file = File('${dir.path}/example.txt');
      await file.writeAsString("File downloaded!");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("File saved at: ${file.path}")),
      );
    }
  } else if (status.isPermanentlyDenied) {
    openAppSettings();
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Storage permission denied.")),
    );
  }
}

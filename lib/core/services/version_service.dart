import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../network/api_client.dart';
import '../values/api_constants.dart';

class VersionService extends GetxService {
  final ApiClient _apiClient = ApiClient();
  bool _isDialogShowing = false;
  String? _latestVersion;
  String? _updateUrl;
  bool _isMandatory = false;

  Future<void> checkVersion() async {
    try {
      // Get current app version info
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      // Call API to check for updates
      final response = await _apiClient.get(ApiConstants.checkVersion);
      debugPrint('Version Check Response: $response');

      if (response != null && response['success'] == true) {
        _latestVersion = response['data']['version'];
        _updateUrl = response['data']['url'];
        _isMandatory = response['data']['isMandatory'] ?? false;

        if (_isVersionLower(currentVersion, _latestVersion!)) {
          _showUpdateDialog();
        }
      }
    } catch (e) {
      debugPrint('Error checking version: $e');
    }
  }

  bool _isVersionLower(String current, String latest) {
    List<int> currentBase = current.split('.').map(int.parse).toList();
    List<int> latestBase = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < latestBase.length; i++) {
      int curr = i < currentBase.length ? currentBase[i] : 0;
      if (latestBase[i] > curr) return true;
      if (latestBase[i] < curr) return false;
    }
    return false;
  }

  void _showUpdateDialog() {
    if (_isDialogShowing) return;
    _isDialogShowing = true;

    Get.dialog(
      PopScope(
        canPop: !_isMandatory,
        onPopInvoked: (didPop) {
          if (didPop) _isDialogShowing = false;
        },
        child: AlertDialog(
          title: const Text(
            'تحديث جديد متوفر',
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: const Text(
            'هناك إصدار جديد من التطبيق متوفر، يرجى التحديث للحصول على آخر المميزات والتحسينات.',
            textAlign: TextAlign.center,
          ),
          actions: [
            if (!_isMandatory)
              TextButton(
                onPressed: () {
                  _isDialogShowing = false;
                  Get.back();
                },
                child: const Text('لاحقاً'),
              ),
            ElevatedButton(
              onPressed: () async {
                if (_updateUrl != null) {
                  final uri = Uri.parse(_updateUrl!);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('تحديث الآن'),
            ),
          ],
        ),
      ),
      barrierDismissible: !_isMandatory,
    ).then((_) => _isDialogShowing = false);
  }

  void checkAndShowIfNeeded() {
    if (_latestVersion != null && _updateUrl != null) {
      PackageInfo.fromPlatform().then((packageInfo) {
        if (_isVersionLower(packageInfo.version, _latestVersion!)) {
          _showUpdateDialog();
        }
      });
    }
  }
}

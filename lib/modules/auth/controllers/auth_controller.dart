import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:game_city_app/core/services/storage_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/invitation_model.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/google_auth_helper.dart';
import '../../../routes/app_routes.dart';

/// ═══════════════════════════════════════════════════════════════
/// إعدادات تسجيل الدخول بواسطة جوجل على ويندوز
/// ═══════════════════════════════════════════════════════════════
/// ⚠️ مهم جداً: يجب استخدام نفس الـ Client ID الذي يستخدمه الويب
/// (uiehqmoi4ufjken3n8g9r2kv865o3e0a) وليس Client ID منفصل.
///
/// السبب: الخادم الخلفي يتحقق من حقل `aud` في التوكن، وهو يطابق
/// الـ Web client ID فقط. إذا استخدمنا Client ID آخر، سيرفض الخادم
/// التوكن برسالة "Google Auth Failed".
///
/// ⚠️ يجب أيضاً وضع الـ Client secret الخاص بالـ Web client
/// (وليس سر الـ Desktop client) في [_windowsGoogleClientSecret].
const String _windowsGoogleClientId =
    '1033131122028-uiehqmoi4ufjken3n8g9r2kv865o3e0a.apps.googleusercontent.com';

/// ⚠️ ضع الـ Client secret الخاص بالـ **Web client** هنا
/// (من Google Cloud Console → Credentials → اضغط على الـ Web client
/// → انسخ "Client secret").
/// بدون هذا القيمة سيظهر خطأ "client_secret is missing".
const String? _windowsGoogleClientSecret =
    "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";

class AuthController extends GetxController {
  final AuthRepository _authRepository = AuthRepository();
  final GetStorage _storage = GetStorage();
  final ImagePicker _picker = ImagePicker();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  var isLoggedIn = false.obs;
  var isLoading = false.obs;
  var userModel = Rxn<UserModel>();
  var socialMediaServices = <SocialMediaService>[].obs;
  var generalInfoTypes = <Map<String, dynamic>>[].obs;

  // Invitation reactive properties
  var myInviteCode = ''.obs;
  var myTeam = <InvitationModel>[].obs;
  var whoInvitedMe = Rxn<InvitationModel>();
  var isInviteCodeLoading = false.obs;
  var isTeamLoading = false.obs;
  var isJoiningTeam = false.obs;

  // Keeping this for backward compatibility with views that use .user['key']
  Map<String, dynamic> get user => userModel.value != null
      ? {
          'userName': userModel.value!.userName,
          'email': userModel.value!.email,
          'firstName': userModel.value!.firstName,
          'lastName': userModel.value!.lastName,
          'points': userModel.value!.points,
          'userImage': userModel.value!.userImage,
          'role': userModel.value!.role,
          '_id': userModel.value!.id,
          'gender': userModel.value!.gender,
          'createdAt': userModel.value!.createdAt,
          'birthDate': userModel.value!.birthDate,
          'phone': userModel.value!.phone,
          'codeInvite': userModel.value!.codeInvite,
          'invitedBy': userModel.value!.invitedBy,
          'userProfile': userModel.value!.userProfile != null
              ? {
                  'bio': userModel.value!.userProfile!.bio,
                  'primaryColor': userModel.value!.userProfile!.primaryColor,
                  'bgProfile': userModel.value!.userProfile!.bgProfile,
                }
              : null,
          'socialMedia': userModel.value!.socialMedia,
          'generalInfo': userModel.value!.generalInfo
              ?.map(
                (info) => {
                  'id': info.id,
                  'title': info.title,
                  'text': info.text,
                  'typeId': info.typeId,
                },
              )
              .toList(),
          'level': userModel.value!.level,
          'levelName': userModel.value!.levelName,
          'levelArabicName': userModel.value!.levelArabicName,
          'levelProgress': userModel.value!.levelProgress,
        }
      : {};

  @override
  void onInit() {
    super.onInit();
    _initializeInternal();
    if (_storage.hasData('token')) {
      isLoggedIn.value = true;
      if (_storage.hasData('user')) {
        try {
          userModel.value = UserModel.fromJson(_storage.read('user'));
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error loading user from storage: $e');
          }
        }
      }
      refreshProfile();
      fetchSocialMediaServices();
      fetchGeneralInfoTypes();
      updateFcmToken();
      loadInvitationData();
    }
  }

  Future<void> fetchGeneralInfoTypes() async {
    try {
      final types = await getInfoTypes();
      generalInfoTypes.value = List<Map<String, dynamic>>.from(types);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching general info types: $e');
      }
    }
  }

  Future<void> fetchSocialMediaServices() async {
    try {
      final services = await getSocialMediaServices();
      socialMediaServices.value = services
          .map((s) => SocialMediaService.fromJson(s))
          .toList();
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching social media services: $e');
      }
    }
  }

  static bool _isGoogleInitialized = false;
  static Future<void>? _googleInitFuture;

  Future<void> _initializeInternal() async {
    if (_isGoogleInitialized) return;

    if (_googleInitFuture != null) {
      return _googleInitFuture;
    }

    try {
      _googleInitFuture = _googleSignIn.initialize(
        clientId: kIsWeb
            ? '1033131122028-uiehqmoi4ufjken3n8g9r2kv865o3e0a.apps.googleusercontent.com'
            : null,
        serverClientId: kIsWeb
            ? null
            : '1033131122028-uiehqmoi4ufjken3n8g9r2kv865o3e0a.apps.googleusercontent.com',
      );
      await _googleInitFuture;
      _isGoogleInitialized = true;
    } catch (e) {
      if (e.toString().contains('init()') ||
          e.toString().contains('already initialized') ||
          e.toString().contains('Bad state')) {
        _isGoogleInitialized = true;
      } else if (kDebugMode) {
        debugPrint('Google Sign-In initialization failed: $e');
      }
    }
  }

  Future<void> updateFcmToken() async {
    try {
      if (!Get.isRegistered<NotificationService>()) {
        return;
      }
      final token = await NotificationService.to.getToken();
      if (token != null) {
        await _authRepository.updateUser({'fcmToken': token});
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating FCM token: $e');
      }
    }
  }

  Future<void> refreshProfile() async {
    try {
      final response = await _authRepository.getProfile();
      // if (response != null ) {
      userModel.value = UserModel.fromJson(response);
      _storage.write('user', response);
      // }
    } catch (e) {
      if (e.toString().contains('Invalid token')) {
        logout();
      }
      if (kDebugMode) {
        debugPrint('Error refreshing profile: $e');
      }
    }
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
    try {
      isLoading.value = true;
      final response = await _authRepository.updateUser(body);
      final userData = response['user'] ?? response;
      userModel.value = UserModel.fromJson(userData);

      // Update local storage
      _storage.write('user', userData);

      Get.back();
      Get.snackbar(
        'نجاح',
        'تم تحديث البيانات',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.white,
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error updating profile: $e');
      }
      Get.snackbar(
        'خطأ',
        'فشل تحديث البيانات: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      final response = await _authRepository.login(email, password);
      final token = response['token'];
      final userData = response['user'];

      if (token != null) {
        await _storage.write('token', token);

        if (userData != null) {
          await _storage.write('user', userData);
          userModel.value = UserModel.fromJson(userData);
        } else {
          await refreshProfile();
        }
        await fetchSocialMediaServices();
        await fetchGeneralInfoTypes();
        isLoggedIn.value = true;
        updateFcmToken();
        Get.snackbar(
          'نجاح',
          'تم تسجيل الدخول بنجاح',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.white,
        );

        Get.offAllNamed(AppRoutes.home);
      } else {
        throw 'فشل تسجيل الدخول: بيانات ناقصة';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint(e.toString());
      }
      Get.snackbar(
        'خطأ',
        'فشل تسجيل الدخول: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle({String? inviteCode}) async {
    // ═══════════════════════════════════════════════════════════
    // 🟦 مراقبة تسجيل الدخول بواسطة جوجل — خطوة بخطوة
    // ═══════════════════════════════════════════════════════════

    try {
      isLoading.value = true;
      String? googleIdToken;

      if (kIsWeb) {
        // ── Web: Firebase Auth signInWithPopup ──

        GoogleAuthProvider googleProvider = GoogleAuthProvider();
        final UserCredential userCredential = await FirebaseAuth.instance
            .signInWithPopup(googleProvider);

        final OAuthCredential? credential =
            userCredential.credential as OAuthCredential?;
        googleIdToken = credential?.idToken;

        if (googleIdToken == null) {
          throw 'لم يتم العثور على رمز توثيق جوجل (Google ID Token) ضمن بيانات الاعتماد.';
        }
      } else if (defaultTargetPlatform == TargetPlatform.windows) {
        // ── Windows: OAuth via system browser + local server ──

        googleIdToken = await signInWithGoogleDesktop(
          clientId: _windowsGoogleClientId,
          clientSecret: _windowsGoogleClientSecret,
          scopes: 'openid email profile',
        );
      } else {
        // ── Android / iOS: google_sign_in native SDK ──

        await _initializeInternal();

        GoogleSignInAccount googleUser;
        try {
          googleUser = await _googleSignIn.authenticate();
        } on GoogleSignInException catch (e) {
          if (e.code == GoogleSignInExceptionCode.canceled) {
            isLoading.value = false;
            return; // User cancelled
          }
          rethrow;
        }

        final GoogleSignInAuthentication googleAuth = googleUser.authentication;
        googleIdToken = googleAuth.idToken;
      }

      if (googleIdToken == null) {
        throw 'فشل الحصول على رمز التوثيق من جوجل. تأكد من إعداد SHA-1 في كونسول فايربيس.';
      }

      // 5. Send the GOOGLE ID Token to your backend server

      if (googleIdToken != "") {
        final response = await _authRepository.loginWithGoogle(
          googleIdToken,
          inviteCode: inviteCode,
        );

        final token = response['token'];
        final userData = response['user'];

        if (token != null) {
          _storage.write('token', token);
          if (userData != null) {
            _storage.write('user', userData);
            userModel.value = UserModel.fromJson(userData);
          } else {
            await refreshProfile();
          }
          await fetchSocialMediaServices();

          await fetchGeneralInfoTypes();

          isLoggedIn.value = true;
          updateFcmToken();
          Get.snackbar(
            'نجاح',
            'تم تسجيل الدخول بواسطة جوجل بنجاح',
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.white,
          );

          Get.offAllNamed(AppRoutes.home);
        } else {
          throw 'فشل تسجيل الدخول: رمز غير صالح من الخادم';
        }
      } else {
        throw 'فشل الحصول على رمز التوثيق من فايربيس';
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تسجيل الدخول بواسطة جوجل: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> register(
    String userName,
    String email,
    String password,
    String firstName,
    String lastName, {
    String? inviteCode,
  }) async {
    try {
      isLoading.value = true;
      final response = await _authRepository.register(
        userName: userName,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        inviteCode: inviteCode,
      );

      final token = response['token'];
      if (token != null) {
        _storage.write('token', token);

        final userData = response['user'];
        if (userData != null) {
          _storage.write('user', userData);
          userModel.value = UserModel.fromJson(userData);
        }

        // Redirect to verification because isVerified is false by default
        Get.offNamed(AppRoutes.verifyAccount, arguments: email);

        Get.snackbar(
          'نجاح',
          'تم إنشاء الحساب بنجاح، يرجى تفعيل بريدك الإلكتروني',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.white,
        );
      } else {
        throw 'فشل الحصول على رمز الامن';
      }
    } catch (e) {
      Get.snackbar(
        'خطأ',
        '$e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadProfileImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        isLoading.value = true;
        final response = await _authRepository.updateUserImage(image.path);
        final userData = response['user'] ?? response;

        if (userData is Map<String, dynamic> && userData.isNotEmpty) {
          userModel.value = UserModel.fromJson(userData);
          _storage.write('user', userData);
        }

        Get.snackbar(
          'نجاح',
          'تم تحديث الصورة الشخصية بنجاح',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("///////////////////////////////");
      debugPrint(e.toString());
      debugPrint("///////////////////////////////");
      Get.snackbar(
        'خطأ',
        'فشل تحديث الصورة: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> uploadProfileBackgroundImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1080,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        isLoading.value = true;
        final response = await _authRepository.updateUserBackgroundImage(
          image.path,
        );
        final userData = response['user'] ?? response;

        if (userData is Map<String, dynamic> && userData.isNotEmpty) {
          userModel.value = UserModel.fromJson(userData);
          _storage.write('user', userData);
        }

        Get.snackbar(
          'نجاح',
          'تم تحديث صورة الغلاف بنجاح',
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("///////////////////////////////");
      debugPrint(e.toString());
      debugPrint("///////////////////////////////");
      Get.snackbar(
        'خطأ',
        'فشل تحديث صورة الغلاف: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteUserInfo(String infoId) async {
    try {
      isLoading.value = true;
      await _authRepository.deleteUserInfo(infoId);
      await refreshProfile();
      Get.snackbar(
        'نجاح',
        'تم حذف المعلومة بنجاح',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حذف المعلومة: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteSocialMediaLink(String linkId) async {
    try {
      isLoading.value = true;
      await _authRepository.deleteSocialMediaLink(linkId);
      await refreshProfile();
      Get.snackbar(
        'نجاح',
        'تم حذف الرابط بنجاح',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل حذف الرابط: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addUserInfo(String typeId, String value) async {
    try {
      isLoading.value = true;
      await _authRepository.addUserInfo(typeId, value);
      await refreshProfile();
      Get.back();
      Get.snackbar(
        'نجاح',
        'تم إضافة المعلومة بنجاح',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل إضافة المعلومة: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<List<dynamic>> getInfoTypes() async {
    try {
      return await _authRepository.getUserInfoTypes();
    } catch (e) {
      return [];
    }
  }

  Future<List<dynamic>> getSocialMediaServices() async {
    try {
      return await _authRepository.getSocialMediaServices();
    } catch (e) {
      return [];
    }
  }

  Future<Map<String, dynamic>> addSocialMediaLink(
    String socialMediaId,
    String username,
  ) async {
    try {
      isLoading.value = true;
      return await _authRepository.addSocialMediaLink(
        socialMediaId: socialMediaId,
        username: username,
      );
    } catch (e) {
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> verifyAccount(String email, String code) async {
    try {
      isLoading.value = true;
      await _authRepository.verifyAccount(email, code);
      Get.offAllNamed(AppRoutes.home);
      Get.snackbar(
        'نجاح',
        'تم تفعيل الحساب بنجاح، يمكنك الآن تسجيل الدخول',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تفعيل الحساب: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      isLoading.value = true;
      await _authRepository.forgotPassword(email);
      Get.toNamed(AppRoutes.resetPassword, arguments: email);
      Get.snackbar(
        'نجاح',
        'تم إرسال رمز إعادة التعيين لبريدك الإلكتروني',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل إرسال الرمز: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resetPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {
      isLoading.value = true;
      await _authRepository.resetPassword(
        email: email,
        code: code,
        newPassword: newPassword,
      );
      Get.offAllNamed(AppRoutes.login);
      Get.snackbar(
        'نجاح',
        'تم تغيير كلمة المرور بنجاح',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تغيير كلمة المرور: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      isLoading.value = true;
      await _authRepository.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      Get.back();
      Get.snackbar(
        'نجاح',
        'تم تغيير كلمة المرور بنجاح',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل تغيير كلمة المرور: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _storage.remove('token');
    _storage.remove('user');
    isLoggedIn.value = false;
    userModel.value = null;

    Get.offAllNamed(AppRoutes.login);

    Get.snackbar(
      'نجاح',
      'تم تسجيل الخروج',
      backgroundColor: Colors.green.withOpacity(0.1),
      colorText: Colors.white,
    );
  }

  // ═══════════════════════════════════════════════════════════════════
  // Invitation Methods
  // ═══════════════════════════════════════════════════════════════════

  /// Validate an invite code (public, no auth needed)
  Future<InvitationValidationResult> validateInviteCode(String code) async {
    try {
      final response = await _authRepository.validateInviteCode(code);
      return InvitationValidationResult.fromJson(response);
    } catch (e) {
      return InvitationValidationResult(
        valid: false,
        message: 'كود الدعوة غير صالح',
      );
    }
  }

  /// Get my invite code
  Future<void> fetchMyInviteCode() async {
    try {
      isInviteCodeLoading.value = true;
      final response = await _authRepository.getMyInviteCode();
      myInviteCode.value = response['codeInvite'] ?? '';
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching invite code: $e');
      }
    } finally {
      isInviteCodeLoading.value = false;
    }
  }

  /// Get my team (people I invited)
  Future<void> fetchMyTeam() async {
    try {
      isTeamLoading.value = true;
      final response = await _authRepository.getMyTeam();
      final teamList = (response['team'] as List? ?? [])
          .map((e) => InvitationModel.fromJson(e))
          .toList();
      myTeam.value = teamList;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching team: $e');
      }
    } finally {
      isTeamLoading.value = false;
    }
  }

  /// Get who invited me
  Future<void> fetchWhoInvitedMe() async {
    try {
      final response = await _authRepository.getWhoInvitedMe();
      final data = WhoInvitedMeResponse.fromJson(response);
      whoInvitedMe.value = data.invitedBy;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching who invited me: $e');
      }
    }
  }

  /// Join a friend's team using their invite code
  Future<bool> joinWithInviteCode(String code) async {
    try {
      isJoiningTeam.value = true;
      await _authRepository.joinWithInviteCode(code);
      await refreshProfile();
      await loadInvitationData();
      Get.snackbar(
        'تم بنجاح',
        'تم الانضمام إلى الفريق بنجاح',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.white,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'خطأ',
        'فشل الانضمام: $e',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.white,
      );
      return false;
    } finally {
      isJoiningTeam.value = false;
    }
  }

  /// Load all invitation data (called once on profile load)
  Future<void> loadInvitationData() async {
    await Future.wait([
      fetchMyInviteCode(),
      fetchMyTeam(),
      fetchWhoInvitedMe(),
    ]);
  }
}

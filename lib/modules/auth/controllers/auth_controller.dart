import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/models/user_model.dart';
import '../../../core/services/notification_service.dart';
import '../../../routes/app_routes.dart';

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

  bool _isGoogleInitialized = false;
  Future<void> _initializeInternal() async {
    if (_isGoogleInitialized) return;
    try {
      await _googleSignIn.initialize(
        serverClientId:
            '1033131122028-uiehqmoi4ufjken3n8g9r2kv865o3e0a.apps.googleusercontent.com',
      );
      _isGoogleInitialized = true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Google Sign-In initialization failed: $e');
      }
    }
  }

  Future<void> updateFcmToken() async {
    try {
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

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;

      // Ensure Google Sign In is initialized once with serverClientId
      await _initializeInternal();

      // 1. Sign in with Google to get account details
      GoogleSignInAccount? googleUser;
      try {
        googleUser = await _googleSignIn.authenticate();
      } on GoogleSignInException catch (e) {
        if (e.code == GoogleSignInExceptionCode.canceled) {
          isLoading.value = false;
          return; // User cancelled
        }
        rethrow;
      }

      // 2. Get authentication details (including tokens)
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      final String? googleIdToken =
          googleAuth.idToken; // هذا هو توكن جوجل المطلوب للسيرفر

      if (googleIdToken == null) {
        throw 'فشل الحصول على رمز التوثيق من جوجل. تأكد من إعداد SHA-1 في كونسول فايربيس.';
      }

      // 5. Send the GOOGLE ID Token to your backend server
      if (googleIdToken != "") {
        final response = await _authRepository.loginWithGoogle(googleIdToken);

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
    String lastName,
  ) async {
    try {
      isLoading.value = true;
      final response = await _authRepository.register(
        userName: userName,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
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
}

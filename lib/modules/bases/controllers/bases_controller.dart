import 'package:get/get.dart';
import '../../../data/models/home_dashboard_model.dart';
import '../../../data/repositories/home_repository.dart';

class BasesController extends GetxController {
  final HomeRepository _repository = HomeRepository();

  var dashboard = Rxn<HomeDashboardModel>();
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard() async {
    try {
      isLoading(true);
      final data = await _repository.getHomeDashboard();
      dashboard.value = data;
    } catch (e) {
      Get.snackbar('خطأ', 'فشل جلب بيانات الواجهة الرئيسية: $e');
    } finally {
      isLoading(false);
    }
  }
}

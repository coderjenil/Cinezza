import 'package:app/models/premium_plan_model.dart';
import 'package:get/get.dart';

import '../api/apsl_api_call.dart';
import '../core/constants/api_end_points.dart';

class PremiumController extends GetxController {
  RxList<PlanModel> premiumPlans = <PlanModel>[].obs;
  RxBool isPlanLoading = false.obs;

  Future<void> fetchPlans() async {
    try {
      var response = await ApiCall.callService(
        requestInfo: APIRequestInfoObj(
          requestType: HTTPRequestType.get,
          url: ApiEndPoints.fetchPremiumPlans,
          headers: ApiHeaders.getHeaders(),
          serviceName: 'Fetch Premium Plans',
          timeSecond: 30,
        ),
      );
      PremiumPlanModel premiumPlanModel = premiumPlanModelFromJson(
        response.body,
      );

      if (premiumPlanModel.plan.isNotEmpty) {
        premiumPlans.value = premiumPlanModel.plan;
      }
    } catch (e) {
      isPlanLoading.value = true;

      rethrow;
    } finally {
      isPlanLoading.value = false;
    }
  }


  
}

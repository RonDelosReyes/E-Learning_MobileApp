import '../../../models/profile/email_request_model.dart';
import '../../services/profile/email_request_service.dart';

class EmailRequestController {
  final EmailRequestService _service = EmailRequestService();

  Future<void> submitRequest(String authId, String newEmail) async {
    final model = EmailRequestModel(authId: authId, newEmail: newEmail);
    return await _service.submitEmailRequest(model);
  }

  Future<void> updateRequest(String authId, String newEmail) async {
    return await _service.updateEmailRequest(authId, newEmail);
  }

  Future<Map<String, dynamic>?> checkPendingRequest(String authId) async {
    return await _service.getPendingRequest(authId);
  }
}

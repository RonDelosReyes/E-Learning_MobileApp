import '../../../models/profile/edit_user_model.dart';
import '../../services/profile/edit_user_service.dart';

class EditUserController {
  final EditUserService _service = EditUserService();

  Future<void> updateProfile(EditUserModel model) async {
    return await _service.updateProfile(model);
  }
}

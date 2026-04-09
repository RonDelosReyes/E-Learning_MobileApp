import '../services/announcement_service.dart';
import '../../models/announcement_model.dart';

class AnnouncementController {
  final AnnouncementService _service = AnnouncementService();

  Future<List<AnnouncementModel>> getLatestAnnouncements() async {
    return await _service.getLatestAnnouncements();
  }

  Future<List<AnnouncementModel>> getAllAnnouncements() async {
    return await _service.getAllAnnouncements();
  }
}

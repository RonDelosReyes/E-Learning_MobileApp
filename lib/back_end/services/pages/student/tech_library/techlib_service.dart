import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../connection/db_connect.dart';
import '../../../../../models/student/tech_library/resource_model.dart';

class TechLibraryService {
  final SupabaseClient _supabase = supabase;

  Future<List<ResourceType>> fetchResourceTypes() async {
    try {
      final response = await _supabase.from('tbl_type').select().order('type');
      return (response as List).map((json) => ResourceType.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching resource types: $e');
      return [];
    }
  }

  Future<List<ResourceModel>> fetchResources({int? typeId}) async {
    try {
      var query = _supabase.from('tbl_resource').select('''
        resource_id,
        title,
        file_url,
        date_uploaded,
        tbl_type(type),
        tbl_category(category),
        tbl_user(firstName, lastName)
      ''');

      if (typeId != null) {
        query = query.eq('type_no', typeId);
      }

      final response = await query.order('date_uploaded', ascending: false);
      return (response as List).map((json) => ResourceModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching resources: $e');
      return [];
    }
  }
}

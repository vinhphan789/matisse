/// Model cho 1 Case
/// Giống Codable struct bên Swift
class ProjectModel {
  final String id;
  final String name;
  final String? patientName;  // ✅ nullable như Swift
  final String? status;
  final String? description;
  final String? createdBy;
  final String? updatedBy;
  final String? createdTs;
  final String? updatedTs;
  final ProjectImageModel? image;
  final DentistModel? dentist;  // ✅ đổi từ String? sang DentistModel?
  final String? role;

  ProjectModel({
    required this.id,
    required this.name,
    this.patientName,
    this.status,
    this.description,
    this.createdBy,
    this.updatedBy,
    this.createdTs,
    this.updatedTs,
    this.image,
    this.dentist,
    this.role,
  });

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProjectModel(
        id:          json['id']            ?? '',
        name:        json['name']          ?? '',
        patientName: json['patient_name'],
        status:      json['status'],
        description: json['description'],
        createdBy:   json['created_by'],
        updatedBy:   json['updated_by'],
        createdTs:   json['created_ts'],
        updatedTs:   json['updated_ts'],
        image: json['image'] != null
            ? ProjectImageModel.fromJson(json['image'])
            : null,
        // ✅ dentist là object, parse an toàn
        dentist: json['dentist'] != null && json['dentist'] is Map
            ? DentistModel.fromJson(json['dentist'])
            : null,
        role: json['role'],
      );
    } catch (e) {
      print('❌ ProjectModel.fromJson ERROR: $e');
      print('❌ JSON: $json');
      rethrow;
    }
  }
}

// ✅ Thêm model mới cho Dentist
class DentistModel {
  final String? id;
  final String? name;
  final String? user;

  DentistModel({this.id, this.name, this.user});

  factory DentistModel.fromJson(Map<String, dynamic> json) {
    return DentistModel(
      id:   json['id']?.toString(),
      name: json['name'],
      user: json['user']?.toString(),
    );
  }
}

// -----------------------------------------------------------

/// Model cho phần image bên trong Case
class ProjectImageModel {
  final int id;
  final String imageUrl;      // URL ảnh chính
  final String type;
  final String? dehazedImage; // Nullable — không phải case nào cũng có
  final String? rawImage;     // URL file raw (.optishade)

  ProjectImageModel({
    required this.id,
    required this.imageUrl,
    required this.type,
    this.dehazedImage,
    this.rawImage,
  });

  factory ProjectImageModel.fromJson(Map<String, dynamic> json) {
    return ProjectImageModel(
      id:           json['id']    ?? 0,
      imageUrl:     json['image'] ?? '',
      type:         json['type']  ?? '',
      dehazedImage: json['dehazed_image']?.isEmpty == true
          ? null
          : json['dehazed_image'], // Trả về null nếu string rỗng ""
      rawImage:     json['raw_image'],
    );
  }
}

// -----------------------------------------------------------

/// Wrapper cho response dạng paginated
/// API trả về: { count, next, previous, results: [...] }
class PaginatedProjects {
  final int count;        // Tổng số case (dùng để biết còn bao nhiêu trang)
  final String? next;     // URL trang tiếp — null nghĩa là hết data
  final String? previous; // URL trang trước — null nghĩa là đang ở trang đầu
  final List<ProjectModel> results;

  PaginatedProjects({
    required this.count,
    required this.next,
    required this.previous,
    required this.results,
  });

  factory PaginatedProjects.fromJson(Map<String, dynamic> json) {
    return PaginatedProjects(
      count:    json['count']    ?? 0,
      next:     json['next'],
      previous: json['previous'],

      // Parse list JSON -> List<CaseModel>
      results: (json['results'] as List? ?? [])
          .map((item) => ProjectModel.fromJson(item))
          .toList(),
    );
  }
}

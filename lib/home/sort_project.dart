// ============================================================
// FILE 1: lib/home/sort_project.dart
// ============================================================

enum SortField { name, createdAt, lastModifiedAt, status }
enum SortOrder { ascending, descending }

class SortProject {
  final SortField field;
  final SortOrder order;

  const SortProject({
    required this.field,
    this.order = SortOrder.ascending,
  });

  SortProject copyWith({SortField? field, SortOrder? order}) {
    return SortProject(
      field: field ?? this.field,
      order: order ?? this.order,
    );
  }

  String get label {
    switch (field) {
      case SortField.name:
        return 'Name';
      case SortField.createdAt:
        return 'Create At';
      case SortField.lastModifiedAt:
        return 'Last modified at';
      case SortField.status:
        return 'Status';
    }
  }
}
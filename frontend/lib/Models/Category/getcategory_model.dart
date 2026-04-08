class GetCategoryModel {
  final String? id;
  final String? category;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GetCategoryModel({
    this.id,
    this.category,
    this.createdAt,
    this.updatedAt,
  });

  factory GetCategoryModel.fromJson(Map<String, dynamic> json) {
    return GetCategoryModel(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
      category: json['category'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'category': category,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

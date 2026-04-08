class ProductCategoryModel {
  final String? id;
  final String? productCategory;
  final String? image;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  ProductCategoryModel({
    this.id,
    this.productCategory,
    this.image,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory ProductCategoryModel.fromJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
      productCategory: json['productCategory'] as String?,
      image: json['image'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productCategory': productCategory,
      'image': image,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      '__v': v,
    };
  }
}

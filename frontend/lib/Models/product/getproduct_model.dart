class GetProductModel {
  final String? id;
  final ProductCategory? productCategory;
  final String? productName;
  final int?productId ;
  final int? tax;
  final String? hsn;
  final double? rate;
  final List<String>? images;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GetProductModel({
    this.id,
    this.productCategory,
    this.productName,
    this.tax,
    this.productId,
    this.hsn,
    this.rate,
    this.images,
    this.createdAt,
    this.updatedAt,
  });

  factory GetProductModel.fromJson(Map<String, dynamic> json) {
    return GetProductModel(
      id: (json['id'] ?? (json['id'] ?? json['_id'])),
      productCategory: json['productCategory'] != null
          ? ProductCategory.fromJson(json['productCategory'])
          : null,
      productName: json['productName'],
      tax: json['tax'],
      productId: json['productId'],
      hsn: json['HSN'],
      rate: (json['rate'] is int)
          ? (json['rate'] as int).toDouble()
          : json['rate'],
      images: (json['images'] as List<dynamic>?)
          ?.map((item) => item.toString())
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productCategory': productCategory?.toJson(),
      'productName': productName,
      'tax': tax,
      'productId': productId,
      'HSN': hsn,
      'rate': rate,
      'images': images,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ProductCategory {
  final String? id;
  final String? productCategory;
  final String? image;

  ProductCategory({this.id, this.productCategory, this.image});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: (json['id'] ?? (json['id'] ?? json['_id'])),
      productCategory: json['productCategory'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productCategory': productCategory,
      'image': image,
    };
  }
}

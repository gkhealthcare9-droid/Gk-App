class GetManufacturerModel {
  final String? id;
  final String? manufacturer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GetManufacturerModel({
    this.id,
    this.manufacturer,
    this.createdAt,
    this.updatedAt,
  });

  factory GetManufacturerModel.fromJson(Map<String, dynamic> json) {
    return GetManufacturerModel(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
      manufacturer: json['manufacturer'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'manufacturer': manufacturer,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}



class GetCustomerProductModel {
  final String? id;
  final Customer? customer;
  final ProductCategory? productCategory;
  final String? slNumber;
  final DateTime? soldDate;
  final DateTime? warranty;
  final DateTime? amcStart;
  final DateTime? amcEnd;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  GetCustomerProductModel({
    this.id,
    this.customer,
    this.productCategory,
    this.slNumber,
    this.soldDate,
    this.warranty,
    this.amcStart,
    this.amcEnd,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory GetCustomerProductModel.fromJson(Map<String, dynamic> json) {
    return GetCustomerProductModel(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
      customer: json['customer'] != null ? Customer.fromJson(json['customer']) : null,
      productCategory: json['productCategory'] != null ? ProductCategory.fromJson(json['productCategory']) : null,
      slNumber: json['slNumber'] as String?,
      soldDate: json['soldDate'] != null ? DateTime.parse(json['soldDate']) : null,
      warranty: json['warranty'] != null ? DateTime.parse(json['warranty']) : null,
      amcStart: json['amcStart'] != null ? DateTime.tryParse(json['amcStart']) : null,
      amcEnd: json['amcEnd'] != null ? DateTime.tryParse(json['amcEnd']) : null,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      v: json['__v'] as int?,
    );
  }
}

class Customer {
  final String? id;
  final String? customerName;

  Customer({
    this.id,
    this.customerName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
      customerName: json['customerName'] as String?,
    );
  }
}

class ProductCategory {
  final String? id;
  final String? productCategory;

  ProductCategory({
    this.id,
    this.productCategory,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
      productCategory: json['productCategory'] as String?,
    );
  }
}



class CustomerProduct {
  final String id;
  final Customer customer;
  final ProductCategory? productCategory;
  final Manufacturer? manufacturer;
  final String slNumber;
  final DateTime soldDate;
  final DateTime warranty;
  final DateTime? amcStart;
  final DateTime? amcEnd;
  final DateTime createdAt;
  final DateTime updatedAt;

  CustomerProduct({
    required this.id,
    required this.customer,
    this.productCategory,
    this.manufacturer,
    required this.slNumber,
    required this.soldDate,
    required this.warranty,
    this.amcStart,
    this.amcEnd,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerProduct.fromJson(Map<String, dynamic> json) {
    return CustomerProduct(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      customer: Customer.fromJson(json['customer']),
      productCategory: json['productCategory'] != null
          ? ProductCategory.fromJson(json['productCategory'])
          : null,
      manufacturer: json['manufacturer'] != null
          ? Manufacturer.fromJson(json['manufacturer'])
          : null,
      slNumber: json['slNumber'] ?? '',
      soldDate: DateTime.parse(json['soldDate']),
      warranty: DateTime.parse(json['warranty']),
      amcStart: json['amcStart'] != null ? DateTime.tryParse(json['amcStart']) : null,
      amcEnd: json['amcEnd'] != null ? DateTime.tryParse(json['amcEnd']) : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customer': customer.toJson(),
      'productCategory': productCategory?.toJson(),
      'manufacturer': manufacturer?.toJson(),
      'slNumber': slNumber,
      'soldDate': soldDate.toIso8601String(),
      'warranty': warranty.toIso8601String(),
      'amcStart': amcStart?.toIso8601String(),
      'amcEnd': amcEnd?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class Customer {
  final String id;
  final String customerName;

  Customer({
    required this.id,
    required this.customerName,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      customerName: json['customerName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customerName': customerName,
    };
  }
}

class ProductCategory {
  final String id;
  final String productCategory;

  ProductCategory({
    required this.id,
    required this.productCategory,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      productCategory: json['productCategory'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'productCategory': productCategory,
    };
  }
}

class Manufacturer {
  final String id;
  final String manufacturer;

  Manufacturer({
    required this.id,
    required this.manufacturer,
  });

  factory Manufacturer.fromJson(Map<String, dynamic> json) {
    return Manufacturer(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      manufacturer: json['manufacturer'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'manufacturer': manufacturer,
    };
  }
}
class PostCustomerProductModel {
  final String customer;
  final String productCategory;
  final String slNumber;
  final String manufacturer;
  final DateTime soldDate;
  final DateTime warranty;
  final DateTime? amcStart;
  final DateTime? amcEnd;

  PostCustomerProductModel({
    required this.customer,
    required this.productCategory,
    required this.slNumber,
    required this.manufacturer,
    required this.soldDate,
    required this.warranty,
    this.amcStart,
    this.amcEnd,
  });

  Map<String, dynamic> toJson() {
    return {
      'customer': customer,
      'productCategory': productCategory,
      'slNumber': slNumber,
      'manufacturer': manufacturer,
      'soldDate': soldDate.toIso8601String(),
      'warranty': warranty.toIso8601String(),
      'amcStart': amcStart?.toIso8601String() ?? '',
      'amcEnd': amcEnd?.toIso8601String() ?? '',
    };
  }

  factory PostCustomerProductModel.fromJson(Map<String, dynamic> json) {
    return PostCustomerProductModel(
      customer: json['customer'] ?? '',
      productCategory: json['productCategory'] ?? '',
      slNumber: json['slNumber'] ?? '',
      manufacturer: json['manufacturer'] ?? '',
      soldDate: DateTime.parse(json['soldDate']),
      warranty: DateTime.parse(json['warranty']),
      amcStart: json['amcStart'] != null && json['amcStart'] != ''
          ? DateTime.tryParse(json['amcStart'])
          : null,
      amcEnd: json['amcEnd'] != null && json['amcEnd'] != ''
          ? DateTime.tryParse(json['amcEnd'])
          : null,
    );
  }
}

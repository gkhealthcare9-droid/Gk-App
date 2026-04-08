// Updated AddEmployeeModel
class AddEmployeeModel {
  final String? name;
  final String? phone;
  final String? email; // New email field
  final DateTime? dob;
  final String? position;
  final String? customer;

  AddEmployeeModel({
    this.name,
    this.phone,
    this.email,
    this.dob,
    this.position,
    this.customer,
  });

  factory AddEmployeeModel.fromJson(Map<String, dynamic> json) {
    return AddEmployeeModel(
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?, // Add email to fromJson
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      position: json['position'] as String?,
      customer: json['customer'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email, // Add email to toJson
      'dob': dob?.toIso8601String(),
      'position': position,
      'customer': customer,
    };
  }
}

// Update GetEmployeeModel to include email
class GetEmployeeModel {
  final String? id;
  final String? name;
  final String? phone;
  final String? email; // New email field
  final DateTime? dob;
  final Position? position;
  final Customer? customer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GetEmployeeModel({
    this.id,
    this.name,
    this.phone,
    this.email,
    this.dob,
    this.position,
    this.customer,
    this.createdAt,
    this.updatedAt,
  });

  factory GetEmployeeModel.fromJson(Map<String, dynamic> json) {
    return GetEmployeeModel(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?, // Add email to fromJson
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      position: json['position'] != null
          ? Position.fromJson(json['position'])
          : null,
      customer: json['customer'] != null
          ? Customer.fromJson(json['customer'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'email': email, // Add email to toJson
      'dob': dob?.toIso8601String(),
      'position': position?.toJson(),
      'customer': customer?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Position {
  final String? id;
  final String? category;

  Position({this.id, this.category});

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
      category: json['category'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'category': category,
    };
  }
}

class Customer {
  final String? id;
  final String? customerName;

  Customer({this.id, this.customerName});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
      customerName: json['customerName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customerName': customerName,
    };
  }
}
class AddCustomerContactModel {
  final String? name;
  final String? phone;
  final String? phone2;
  final String? email;
  final String? position; // This will be the positionId
  final String? customer; // This will be the customerId

  AddCustomerContactModel({
    this.name,
    this.phone,
    this.phone2,
    this.email,
    this.position,
    this.customer,
  });

  factory AddCustomerContactModel.fromJson(Map<String, dynamic> json) {
    return AddCustomerContactModel(
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      phone2: json['phone2'] as String?,
      email: json['email'] as String?,
      position: json['positionId']?.toString(),
      customer: json['customerId']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'phone2': phone2,
      'email': email,
      'position': position,
      'customer': customer,
    };
  }
}

class GetCustomerContactModel {
  final String? id;
  final String? name;
  final String? phone;
  final String? phone2;
  final String? email;
  final ContactPositionModel? position;
  final ContactCustomerModel? customer;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GetCustomerContactModel({
    this.id,
    this.name,
    this.phone,
    this.phone2,
    this.email,
    this.position,
    this.customer,
    this.createdAt,
    this.updatedAt,
  });

  factory GetCustomerContactModel.fromJson(Map<String, dynamic> json) {
    return GetCustomerContactModel(
      id: json['id']?.toString(),
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      phone2: json['phone2'] as String?,
      email: json['email'] as String?,
      position: json['position'] != null
          ? ContactPositionModel.fromJson(json['position'])
          : null,
      customer: json['customer'] != null
          ? ContactCustomerModel.fromJson(json['customer'])
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
      'id': id,
      'name': name,
      'phone': phone,
      'phone2': phone2,
      'email': email,
      'position': position?.toJson(),
      'customer': customer?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class ContactPositionModel {
  final String? id;
  final String? position;

  ContactPositionModel({this.id, this.position});

  factory ContactPositionModel.fromJson(Map<String, dynamic> json) {
    return ContactPositionModel(
      id: json['id']?.toString(),
      position: json['position'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'position': position,
    };
  }
}

class ContactCustomerModel {
  final String? id;
  final String? customerName;

  ContactCustomerModel({this.id, this.customerName});

  factory ContactCustomerModel.fromJson(Map<String, dynamic> json) {
    return ContactCustomerModel(
      id: json['id']?.toString(),
      customerName: json['customerName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerName': customerName,
    };
  }
}

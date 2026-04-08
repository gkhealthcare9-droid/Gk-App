class OutstandingModel {
  final String id;
  final int initialDue;
  final int currentDue;
  final Customer customer;
  final List<String> payments;
  final int v;

  OutstandingModel({
    required this.id,
    required this.initialDue,
    required this.currentDue,
    required this.customer,
    required this.payments,
    required this.v,
  });

  factory OutstandingModel.fromJson(Map<String, dynamic> json) {
    return OutstandingModel(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      initialDue: json['initialDue'] as int? ?? 0,
      currentDue: json['currentDue'] as int? ?? 0,
      customer: Customer.fromJson(json['customer'] as Map<String, dynamic>? ?? {}),
      payments: (json['payments'] as List<dynamic>?)
          ?.cast<String>()
          .toList() ??
          [],
      v: json['__v'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'initialDue': initialDue,
      'currentDue': currentDue,
      'customer': customer.toJson(),
      'payments': payments,
      '__v': v,
    };
  }
}

class Customer {
  final String id;
  final String customerName;
  final String customerPhone;
  final String? customerPhone2;
  final String customerEmail;
  final String customerGSTIN;
  final String customerCompany;
  final String customerQuniqueNumber;
  final String addressOne;
  final String? addressTwo;
  final String city;
  final String state;
  final String pincode;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Customer({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    this.customerPhone2,
    required this.customerEmail,
    required this.customerGSTIN,
    required this.customerCompany,
    required this.customerQuniqueNumber,
    required this.addressOne,
    this.addressTwo,
    required this.city,
    required this.state,
    required this.pincode,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      customerName: json['customerName'] as String? ?? '',
      customerPhone: json['customerPhone'] as String? ?? '',
      customerPhone2: json['customerPhone2'] as String?,
      customerEmail: json['customerEmail'] as String? ?? '',
      customerGSTIN: json['customerGSTIN'] as String? ?? '',
      customerCompany: json['customerCompany'] as String? ?? '',
      customerQuniqueNumber: json['customerQuniqueNumber'] as String? ?? '',
      addressOne: json['addressOne'] as String? ?? '',
      addressTwo: json['addressTwo'] as String?,
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      pincode: json['pincode'] as String? ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(),
      v: json['__v'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerPhone2': customerPhone2,
      'customerEmail': customerEmail,
      'customerGSTIN': customerGSTIN,
      'customerCompany': customerCompany,
      'customerQuniqueNumber': customerQuniqueNumber,
      'addressOne': addressOne,
      'addressTwo': addressTwo,
      'city': city,
      'state': state,
      'pincode': pincode,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}
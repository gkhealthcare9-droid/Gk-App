class CustomerOutstandingModel {
  final String id;
  final int initialDue;
  final int currentDue;
  final String customer; // Just customer ID string
  final List<Payment> payments;
  final int v;

  CustomerOutstandingModel({
    required this.id,
    required this.initialDue,
    required this.currentDue,
    required this.customer,
    required this.payments,
    required this.v,
  });

  factory CustomerOutstandingModel.fromJson(Map<String, dynamic> json) {
    return CustomerOutstandingModel(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      initialDue: json['initialDue'] ?? 0,
      currentDue: json['currentDue'] ?? 0,
      customer: json['customer'] ?? '',
      payments: (json['payments'] as List<dynamic>?)
          ?.map((p) => Payment.fromJson(p))
          .toList() ??
          [],
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'initialDue': initialDue,
      'currentDue': currentDue,
      'customer': customer,
      'payments': payments.map((p) => p.toJson()).toList(),
      '__v': v,
    };
  }
}
class Payment {
  final String id;
  final String customer;
  final int amount;
  final String type;
  final String invoiceNumber;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Payment({
    required this.id,
    required this.customer,
    required this.amount,
    required this.type,
    required this.invoiceNumber,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      customer: json['customer'] ?? '',
      amount: json['amount'] ?? 0,
      type: json['type'] ?? '',
      invoiceNumber: json['invoiceNumber'] ?? '',
      description: json['description'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      v: json['__v'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'customer': customer,
      'amount': amount,
      'type': type,
      'invoiceNumber': invoiceNumber,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class Customer {
  final String id;
  final String customerName;
  final String customerPhone;
  final String customerPhone2;
  final String customerEmail;
  final String customerGSTIN;
  final String customerCompany;
  final String customerQuniqueNumber;
  final String addressOne;
  final String addressTwo;
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
    required this.customerPhone2,
    required this.customerEmail,
    required this.customerGSTIN,
    required this.customerCompany,
    required this.customerQuniqueNumber,
    required this.addressOne,
    required this.addressTwo,
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
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      customerPhone2: json['customerPhone2'] ?? '',
      customerEmail: json['customerEmail'] ?? '',
      customerGSTIN: json['customerGSTIN'] ?? '',
      customerCompany: json['customerCompany'] ?? '',
      customerQuniqueNumber: json['customerQuniqueNumber'] ?? '',
      addressOne: json['addressOne'] ?? '',
      addressTwo: json['addressTwo'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      v: json['__v'] ?? 0,
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

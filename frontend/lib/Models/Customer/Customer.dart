class CustomerModel {
  final String? id;
  final String? customerName;
  final String? customerPhone;
  final String? customerPhone2;
  final String? customerEmail;
  final String? customerGSTIN;
  final String? customerCompany;
  final String? customerQuniqueNumber;
  final String? addressOne;
  final String? addressTwo;
  final String? city;
  final String? state;
  final String? pincode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerModel({
    this.id,
    this.customerName,
    this.customerPhone,
    this.customerPhone2,
    this.customerEmail,
    this.customerGSTIN,
    this.customerCompany,
    this.customerQuniqueNumber,
    this.addressOne,
    this.addressTwo,
    this.city,
    this.state,
    this.pincode,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) => CustomerModel(
    id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
    customerName: json['customerName'] as String?,
    customerPhone: json['customerPhone'] as String?,
    customerPhone2: json['customerPhone2'] as String?,
    customerEmail: json['customerEmail'] as String?,
    customerGSTIN: json['customerGSTIN'] as String?,
    customerCompany: json['customerCompany'] as String?,
    customerQuniqueNumber: json['customerQuniqueNumber'] as String?,
    addressOne: json['addressOne'] as String?,
    addressTwo: json['addressTwo'] as String?,
    city: json['city'] as String?,
    state: json['state'] as String?,
    pincode: json['pincode'] as String?,
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
  );

  Map<String, dynamic> toJson() => {
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
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}

class AddCustomerModel {
  final String? customerName;
  final String? customerPhone;
  final String? customerPhone2;
  final String? customerEmail;
  final String? customerGSTIN;
  final String? customerCompany;
  final String? addressOne;
  final String? addressTwo;
  final String? city;
  final String? state;
  final String? pincode;

  AddCustomerModel({
    this.customerName,
    this.customerPhone,
    this.customerPhone2,
    this.customerEmail,
    this.customerGSTIN,
    this.customerCompany,
    this.addressOne,
    this.addressTwo,
    this.city,
    this.state,
    this.pincode,
  });

  factory AddCustomerModel.fromJson(Map<String, dynamic> json) {
    return AddCustomerModel(
      customerName: json['customerName'] as String?,
      customerPhone: json['customerPhone'] as String?,
      customerPhone2: json['customerPhone2'] as String?,
      customerEmail: json['customerEmail'] as String?,
      customerGSTIN: json['customerGSTIN'] as String?,
      customerCompany: json['customerCompany'] as String?,
      addressOne: json['addressOne'] as String?,
      addressTwo: json['addressTwo'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerEmail': customerEmail,
      'customerGSTIN': customerGSTIN,
      'customerCompany': customerCompany,
      'addressOne': addressOne,
      'addressTwo': addressTwo,
      'city': city,
      'state': state,
      'pincode': pincode,
    };

    // Only include customerPhone2 if it's not null or empty
    if (customerPhone2 != null && customerPhone2!.trim().isNotEmpty) {
      map['customerPhone2'] = customerPhone2;
    }

    return map;
  }

}

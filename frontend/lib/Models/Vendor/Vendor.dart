class VendorModel {
  final String? id;
  final String? vendorQuniqeNumber;
  final String? vendorName;
  final String? vendorPhone;
  final String? vendorEmail;
  final String? vendorGSTIN;
  final String? vendorCompany;
  final String? addressOne;
  final String? addressTwo;
  final String? city;
  final String? state;
  final String? pincode;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  VendorModel({
    this.id,
    this.vendorQuniqeNumber,
    this.vendorName,
    this.vendorPhone,
    this.vendorEmail,
    this.vendorGSTIN,
    this.vendorCompany,
    this.addressOne,
    this.addressTwo,
    this.city,
    this.state,
    this.pincode,
    this.createdAt,
    this.updatedAt,
  });

  factory VendorModel.fromJson(Map<String, dynamic> json) {
    return VendorModel(
      vendorQuniqeNumber: json['vendorQuniqueNumber'] as String?,
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
      vendorName: json['vendorName'] as String?,
      vendorPhone: json['vendorPhone'] as String?,
      vendorEmail: json['vendorEmail'] as String?,
      vendorGSTIN: json['vendorGSTIN'] as String?,
      vendorCompany: json['vendorCompany'] as String?,
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
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'vendorName': vendorName,
      'vendorQuniqeNumber': vendorQuniqeNumber,
      'vendorPhone': vendorPhone,
      'vendorEmail': vendorEmail,
      'vendorGSTIN': vendorGSTIN,
      'vendorCompany': vendorCompany,
      'addressOne': addressOne,
      'addressTwo': addressTwo,
      'city': city,
      'state': state,
      'pincode': pincode,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class AddVendorModel {
  final String? vendorName;
  final String? vendorPhone;
  final String? vendorEmail;
  final String? vendorGSTIN;
  final String? vendorCompany;
  final String? addressOne;
  final String? addressTwo;
  final String? city;
  final String? state;
  final String? pincode;

  AddVendorModel({
    this.vendorName,
    this.vendorPhone,
    this.vendorEmail,
    this.vendorGSTIN,
    this.vendorCompany,
    this.addressOne,
    this.addressTwo,
    this.city,
    this.state,
    this.pincode,
  });

  factory AddVendorModel.fromJson(Map<String, dynamic> json) {
    return AddVendorModel(
      vendorName: json['vendorName'] as String?,
      vendorPhone: json['vendorPhone'] as String?,
      vendorEmail: json['vendorEmail'] as String?,
      vendorGSTIN: json['vendorGSTIN'] as String?,
      vendorCompany: json['vendorCompany'] as String?,
      addressOne: json['addressOne'] as String?,
      addressTwo: json['addressTwo'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vendorName': vendorName,
      'vendorPhone': vendorPhone,
      'vendorEmail': vendorEmail,
      'vendorGSTIN': vendorGSTIN,
      'vendorCompany': vendorCompany,
      'addressOne': addressOne,
      'addressTwo': addressTwo,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }
}

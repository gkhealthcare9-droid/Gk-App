class AddvendorEmployee {
  final String? name;
  final String? phone;
  final DateTime? dob;
  final String? position;  // categoryId
  final String? vendor;  // customerId

  AddvendorEmployee({
    this.name,
    this.phone,
    this.dob,
    this.position,
    this.vendor,
  });

  factory AddvendorEmployee.fromJson(Map<String, dynamic> json) {
    return AddvendorEmployee(
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      position: json['position'] as String?,
      vendor: json['vendor'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'dob': dob?.toIso8601String(),
      'position': position,
      'vendor': vendor,
    };
  }
}


class GetvendorEmployee {
  final String? id;
  final String? name;
  final String? phone;
  final DateTime? dob;
  final Position? position;
  final Vendor? vendor;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GetvendorEmployee({
    this.id,
    this.name,
    this.phone,
    this.dob,
    this.position,
    this.vendor,
    this.createdAt,
    this.updatedAt,
  });

  factory GetvendorEmployee.fromJson(Map<String, dynamic> json) {
    return GetvendorEmployee(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      position: json['position'] != null
          ? Position.fromJson(json['position'])
          : null,
      vendor: json['vendor'] != null
          ? Vendor.fromJson(json['vendor'])
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
      'dob': dob?.toIso8601String(),
      'position': position?.toJson(),
      'vendor': vendor?.toJson(),
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



class Vendor {
  final String? id;
  final String? vendorName;

  Vendor({this.id, this.vendorName});

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
      vendorName: json['vendorName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'vendorName': vendorName,
    };
  }
}


class PostLead {
  String name;
  String email;
  String phone;
  String address;
  String position;
  String city;
  String assigned;
  String state;
  String company;
  String description;
  String source;
  String leadType;
  String status;
  String category;
  int? leadValue;

  PostLead({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.category,
    required this.position,
    required this.city,
    required this.assigned,
    required this.state,
    required this.company,
    required this.status,
    required this.description,
    required this.source,
    required this.leadType,
    this.leadValue,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
    'address': address,
    'position': position,
    'category': category,
    'city': city,
    'assigned': assigned,
    'state': state,
    'company': company,
    'status': status,
    'description': description,
    'source': source,
    'lead_type': leadType,
    // Note: Check if server expects 'lead_type' or 'leadType'
    'lead_value': leadValue,
    // Note: Check if server expects 'lead_value' or 'leadValue'
  };
}

class LeadModel {
  final String? id;
  final String? name;
  final String? address;
  final String? position;
  final String? city;
  final String? email;
  final String? state;
  final String? phone;
  final String? company;
  final String? description;
  final String? status;
  final UserModel? assigned;
  final String? source;
  final String? leadType;
  final int? leadValue;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeadModel({
    this.id,
    this.name,
    this.address,
    this.position,
    this.city,
    this.email,
    this.state,
    this.phone,
    this.company,
    this.description,
    this.status,
    this.assigned,
    this.source,
    this.leadType,
    this.leadValue,
    this.createdAt,
    this.updatedAt,
  });

  factory LeadModel.fromJson(Map<String, dynamic> json) {
    return LeadModel(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
      name: json['name'] as String?,
      address: json['address'] as String?,
      position: json['position'] as String?,
      city: json['city'] as String?,
      email: json['email'] as String?,
      state: json['state'] as String?,
      phone: json['phone'] as String?,
      company: json['company'] as String?,
      description: json['description'] as String?,
      status: json['status'] is String ? json['status'] : null,
      assigned:
          json['assigned'] != null
              ? (json['assigned'] is Map<String, dynamic>
                  ? UserModel.fromJson(json['assigned'])
                  : null)
              : null,
      source: json['source'] as String?,
      leadType: json['leadType'] as String?,
      leadValue:
          json['leadValue'] != null
              ? (json['leadValue'] is int
                  ? json['leadValue']
                  : int.tryParse(json['leadValue'].toString()))
              : null,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'position': position,
      'city': city,
      'email': email,
      'state': state,
      'phone': phone,
      'company': company,
      'description': description,
      'status': status,
      'assigned': assigned?.toJson(),
      'source': source,
      'leadType': leadType,
      'leadValue': leadValue,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class UserModel {
  final String? id;
  final String? name;

  UserModel({this.id, this.name});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(), name: json['name'] as String?);
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}

class AssignedUser {
  final String? id;
  final String? name;
  final String? email;
  final String? phone;
  final String? password;
  final bool? isActive;
  final String? userType;
  final DateTime? dob;
  final DateTime? doj;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;

  AssignedUser({
    this.id,
    this.name,
    this.email,
    this.phone,
    this.password,
    this.isActive,
    this.userType,
    this.dob,
    this.doj,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
  });

  factory AssignedUser.fromJson(Map<String, dynamic> json) {
    return AssignedUser(
      id: (json['id'] ?? (json['id'] ?? json['_id'])),
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      password: json['password'],
      isActive: json['isActive'],
      userType: json['userType'],
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      doj: json['doj'] != null ? DateTime.tryParse(json['doj']) : null,
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'])
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'])
              : null,
      lastLogin:
          json['lastLogin'] != null
              ? DateTime.tryParse(json['lastLogin'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'isActive': isActive,
      'userType': userType,
      'dob': dob?.toIso8601String(),
      'doj': doj?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'lastLogin': lastLogin?.toIso8601String(),
    };
  }
}

class FollowUpModel {
  final String? id;
  final LeadModel? lead;
  final DateTime? datetime;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  FollowUpModel({
    this.id,
    this.lead,
    this.datetime,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory FollowUpModel.fromJson(Map<String, dynamic> json) {
    return FollowUpModel(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
      lead:
          json['lead'] != null
              ? (json['lead'] is Map<String, dynamic>
                  ? LeadModel.fromJson(json['lead'])
                  : null) // Handle case where lead is a string (e.g., lead ID)
              : null,
      datetime:
          json['datetime'] != null ? DateTime.parse(json['datetime']) : null,
      notes: json['notes'] as String?,
      createdAt:
          json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }
}

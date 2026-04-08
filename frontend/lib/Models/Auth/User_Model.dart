class UserModel {
  final String? id;
  final String? userType;
  final String? name;
  final String? phone;
  final String? email;
  final bool? isActive;
  final DateTime? dob;
  final DateTime? doj;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastLogin;
  final String? telleResponse;

  UserModel({
    this.id,
    this.telleResponse,
    this.userType,
    this.name,
    this.phone,
    this.email,
    this.isActive,
    this.dob,
    this.doj,
    this.createdAt,
    this.updatedAt,
    this.lastLogin,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString(),
    telleResponse: json['telleResponse'] as String?,
    userType: json['userType'] as String?,
    name: json['name'] as String?,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    isActive: json['isActive'] as bool?,
    dob: json['dob'] != null ? DateTime.parse(json['dob']) : null,
    doj: json['doj'] != null ? DateTime.parse(json['doj']) : null,
    createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    lastLogin: json['lastLogin'] != null ? DateTime.parse(json['lastLogin']) : null,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'telleResponse': telleResponse,
    'userType': userType,
    'name': name,
    'phone': phone,
    'email': email,
    'isActive': isActive,
    'dob': dob?.toIso8601String(),
    'doj': doj?.toIso8601String(),
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'lastLogin': lastLogin?.toIso8601String(),
  };
}

class UsersModels {
  final String id;
  final String name;
  final String? phone;
  final String? userType;

  UsersModels({
    required this.id,
    required this.name,
    this.phone,
    this.userType,
  });

  factory UsersModels.fromJson(Map<String, dynamic> json) {
    return UsersModels(
      id: (json['id'] ?? (json['_id'] ?? json['id']))?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unnamed',
      phone: json['phone']?.toString(),
      userType: json['userType'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'phone': phone,
      'userType': userType,
    };
  }
}

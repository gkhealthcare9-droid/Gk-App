class UsersModels {
  final String id;
  final String name;

  final String? userType;


  UsersModels({
    required this.id,
    required this.name,

    this.userType,

  });

  factory UsersModels.fromJson(Map<String, dynamic> json) {
    return UsersModels(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      name: json['name'] as String,

      userType: json['userType'] as String?,

    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,

      'userType': userType,

    };
  }
}
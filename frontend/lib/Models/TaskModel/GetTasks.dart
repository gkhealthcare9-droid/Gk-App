class AssignedTo {
  final String id;
  final String name;
  final String email;

  AssignedTo({required this.id, required this.name, required this.email});

  factory AssignedTo.fromJson(Map<String, dynamic> json) {
    return AssignedTo(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      name: json['name'] as String ?? "",
      email: json['email'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'email': email};
  }
}

class Task {
  final String id;
  final int taskNumber;
  final String taskCategory;
  final String taskName;
  final String taskDescription;
  final String taskStatus;
  final AssignedTo assignedTo;
  final DateTime dueDate;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  Task({
    required this.id,
    required this.taskNumber,
    required this.taskCategory,
    required this.taskName,
    required this.taskDescription,
    required this.taskStatus,
    required this.assignedTo,
    required this.dueDate,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      taskNumber: json['taskNumber'] as int,
      taskCategory: json['taskCategory'] as String,
      taskName: json['taskName'] as String,
      taskDescription: json['taskDescription'] as String,
      taskStatus: json['taskStatus'] as String,
      assignedTo: AssignedTo.fromJson(
        json['assignedTo'] as Map<String, dynamic>,
      ),
      dueDate: DateTime.parse(json['dueDate'] as String),
      priority: json['priority'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'taskNumber': taskNumber,
      'taskCategory': taskCategory,
      'taskName': taskName,
      'taskDescription': taskDescription,
      'taskStatus': taskStatus,
      'assignedTo': assignedTo.toJson(),
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

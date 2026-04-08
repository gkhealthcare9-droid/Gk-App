// lib/Models/TaskModel/task_model.dart


class TaskModel {
  final String id;
  final int taskNumber;
  final String taskCategory;
  final String taskName;
  final String taskDescription;
  final String taskStatus;
  final String assignedTo;
  final DateTime dueDate;
  final String priority;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskModel({
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

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      taskNumber: json['taskNumber'] as int,
      taskCategory: json['taskCategory'] as String,
      taskName: json['taskName'] as String,
      taskDescription: json['taskDescription'] as String,
      taskStatus:json['taskStatus'] as String,
      assignedTo: json['assignedTo'] as String,
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
      'assignedTo': assignedTo,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  TaskModel copyWith({
    String? id,
    int? taskNumber,
    String? taskCategory,
    String? taskName,
    String? taskDescription,
    String? taskStatus,
    String? assignedTo,
    DateTime? dueDate,
    String? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      taskNumber: taskNumber ?? this.taskNumber,
      taskCategory: taskCategory ?? this.taskCategory,
      taskName: taskName ?? this.taskName,
      taskDescription: taskDescription ?? this.taskDescription,
      taskStatus: taskStatus ?? this.taskStatus,
      assignedTo: assignedTo ?? this.assignedTo,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

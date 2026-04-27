class AssignedTo {
  final String id;
  final String name;
  final String email;

  AssignedTo({required this.id, required this.name, required this.email});

  factory AssignedTo.fromJson(Map<String, dynamic> json) {
    return AssignedTo(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      name: json['name'] as String? ?? "",
      email: json['email'] as String? ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email};
  }
}

class TaskCustomer {
  final String id;
  final String? customerCompany;
  final String? customerName;

  TaskCustomer({required this.id, this.customerCompany, this.customerName});

  factory TaskCustomer.fromJson(Map<String, dynamic> json) {
    return TaskCustomer(
      id: (json['id'] ?? json['_id'])?.toString() ?? '',
      customerCompany: json['customerCompany'] as String?,
      customerName: json['customerName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'customerCompany': customerCompany, 'customerName': customerName};
  }
}

class Task {
  final String id;
  final int taskNumber;
  final String taskCategory;
  final String taskName;
  final String taskDescription;
  final String taskStatus;
  final AssignedTo? assignedTo;
  final TaskCustomer? customer;
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
    this.assignedTo,
    this.customer,
    required this.dueDate,
    required this.priority,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      taskNumber: json['taskNumber'] is int ? json['taskNumber'] : int.tryParse(json['taskNumber']?.toString() ?? '0') ?? 0,
      taskCategory: json['taskCategory']?.toString() ?? '',
      taskName: json['taskName']?.toString() ?? '',
      taskDescription: json['taskDescription']?.toString() ?? '',
      taskStatus: json['taskStatus']?.toString() ?? '',
      assignedTo: json['assignedTo'] != null && json['assignedTo'] is Map<String, dynamic>
          ? AssignedTo.fromJson(json['assignedTo'] as Map<String, dynamic>)
          : null,
      customer: json['Customer'] != null && json['Customer'] is Map<String, dynamic>
          ? TaskCustomer.fromJson(json['Customer'] as Map<String, dynamic>)
          : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : DateTime.now(),
      priority: json['priority']?.toString() ?? 'Medium',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskNumber': taskNumber,
      'taskCategory': taskCategory,
      'taskName': taskName,
      'taskDescription': taskDescription,
      'taskStatus': taskStatus,
      'assignedTo': assignedTo?.toJson(),
      'customer': customer?.toJson(),
      'dueDate': dueDate.toIso8601String(),
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

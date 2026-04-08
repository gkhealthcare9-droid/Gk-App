class ExpenseModel {
  final String? id;
  final String? user;
  final double? balance;
  final List<String>? transactions;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ExpenseModel({
    this.id,
    this.user,
    this.balance,
    this.transactions,
    this.createdAt,
    this.updatedAt,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: (json['id'] ?? (json['id'] ?? json['_id'])),
      user: json['user'],
      balance: (json['balance'] as num?)?.toDouble(),
      transactions: (json['String'] as List<String>?),

      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'balance': balance,
      'transactions': transactions,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}






class ExpensesCategoryModel {
  final String id;
  final String expensesCategory;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  ExpensesCategoryModel({
    required this.id,
    required this.expensesCategory,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  ExpensesCategoryModel copyWith({
    String? id,
    String? expensesCategory,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return ExpensesCategoryModel(
      id: id ?? this.id,
      expensesCategory: expensesCategory ?? this.expensesCategory,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }

  factory ExpensesCategoryModel.fromJson(Map<String, dynamic> json) {
    return ExpensesCategoryModel(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      expensesCategory: json['expensesCategory'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      v: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'expensesCategory': expensesCategory,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }

  @override
  String toString() {
    return 'ExpensesCategoryModel(id: $id, expensesCategory: $expensesCategory, createdAt: $createdAt, updatedAt: $updatedAt, v: $v)';
  }
}


class TransactionModel {
  final String id;
  final String user;
  final int amount;
  final String? categoryId;
  final ExpensesCategoryModel? category;
  final String type;
  final String? bill;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  TransactionModel({
    required this.id,
    required this.user,
    required this.amount,
    this.categoryId,
    this.category,
    required this.type,
    this.bill,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  TransactionModel copyWith({
    String? id,
    String? user,
    int? amount,
    String? categoryId,
    ExpensesCategoryModel? category,
    String? type,
    String? bill,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      user: user ?? this.user,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      category: category ?? this.category,
      type: type ?? this.type,
      bill: bill ?? this.bill,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    String? catId;
    ExpensesCategoryModel? cat;
    final catJson = json['category'];
    if (catJson is String) {
      catId = catJson;
    } else if (catJson is Map<String, dynamic>) {
      cat = ExpensesCategoryModel.fromJson(catJson);
      catId = cat.id;
    }

    return TransactionModel(
      id: (json['id'] ?? (json['id'] ?? (json['id'] ?? json['_id'])))?.toString() ?? '',
      user: json['user'] as String,
      amount: (json['amount'] as num).toInt(),
      categoryId: catId,
      category: cat,
      type: json['type'] as String,
      bill: json['bill'] as String?,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      v: json['__v'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'amount': amount,
      'category': category != null ? category!.toJson() : categoryId,
      'type': type,
      'bill': bill,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }

  @override
  String toString() {
    return 'TransactionModel(id: $id, user: $user, amount: $amount, categoryId: $categoryId, category: $category, type: $type, bill: $bill, description: $description, createdAt: $createdAt, updatedAt: $updatedAt, v: $v)';
  }
}
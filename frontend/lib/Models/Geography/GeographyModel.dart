// frontend/lib/Models/Geography/GeographyModel.dart

class StateModel {
  final int? id;
  final String? name;

  StateModel({this.id, this.name});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
  };
}

class CityModel {
  final int? id;
  final String? name;
  final int? stateId;
  final StateModel? state;

  CityModel({this.id, this.name, this.stateId, this.state});

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'],
      name: json['name'],
      stateId: json['stateId'],
      state: json['State'] != null ? StateModel.fromJson(json['State']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'stateId': stateId,
  };
}

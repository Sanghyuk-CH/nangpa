class IngredientModel {
  int id;
  String name;
  String iconName;
  int expiryDate;
  DateTime expiryAt;
  DateTime createdAt;
  String keepState; // refrigerate(냉장), freezing(냉동), roomTemperature(실온)
  IngredientCategoryModel category;

  IngredientModel({
    required this.id,
    required this.name,
    required this.iconName,
    required this.category,
    required this.createdAt,
    required this.expiryAt,
    required this.expiryDate,
    required this.keepState,
  });

  IngredientModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        iconName = json['icon_name'],
        expiryAt = DateTime.now().add(Duration(
            days:
                IngredientCategoryModel.fromJson(json['category']).expiryDate)),
        expiryDate =
            IngredientCategoryModel.fromJson(json['category']).expiryDate,
        createdAt = DateTime.now(),
        category = IngredientCategoryModel.fromJson(json['category']),
        keepState = json['keep_state'] ?? 'refrigerate';

  IngredientModel.fromSharedJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        iconName = json['iconName'],
        expiryAt = DateTime.parse(json['expiryAt']),
        expiryDate = json['expiryDate'],
        createdAt = DateTime.parse(json['createdAt']),
        category = IngredientCategoryModel.fromSharedJson(json['category']),
        keepState = json['keepState'] ?? 'refrigerate';

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconName': iconName,
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'expiryAt': expiryAt.toIso8601String(),
      'expiryDate': expiryDate,
      'keepState': keepState,
    };
  }

  IngredientModel copyWith({
    int? id,
    String? name,
    String? iconName,
    int? expiryDate,
    DateTime? expiryAt,
    DateTime? createdAt,
    String? keepState,
    IngredientCategoryModel? category,
  }) {
    return IngredientModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      expiryDate: expiryDate ?? this.expiryDate,
      expiryAt: expiryAt ?? this.expiryAt,
      createdAt: createdAt ?? this.createdAt,
      keepState: keepState ?? this.keepState,
      category: category ?? this.category,
    );
  }
}

class IngredientCategoryModel {
  int id, expiryDate;
  String name;

  IngredientCategoryModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        expiryDate = json['expiry_date'];

  IngredientCategoryModel.fromSharedJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        expiryDate = json['expiryDate'];

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'expiryDate': expiryDate,
    };
  }
}

class IngredientListModel {
  Map<String, List<IngredientModel>> categorisedList;
  List<IngredientModel> ingredientList;

  IngredientListModel.fromJson(Map<String, dynamic> json)
      : categorisedList = (json['categorisedList'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(
                key,
                List<IngredientModel>.from(
                    value.map((i) => IngredientModel.fromJson(i))))),
        ingredientList = (json['ingredientList'] as List)
            .map((r) => IngredientModel.fromJson(r))
            .toList();
}

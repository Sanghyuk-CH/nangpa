class MenuModel {
  int id;
  String name, way, ingredientDescriptionText, url;
  List<RecipeModel> recipe;
  List<MenuIngredient>? ingredientRequiredList, ingredientOptionalList;

  MenuModel({
    required this.id,
    required this.name,
    required this.way,
    required this.ingredientDescriptionText,
    required this.url,
    required this.recipe,
    this.ingredientOptionalList,
    this.ingredientRequiredList,
  });

  MenuModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        way = json['way'],
        ingredientDescriptionText = json['ingredient_description_text'],
        url = json['url'],
        recipe = List<RecipeModel>.from(json['recipe']
            .map((recipeJson) => RecipeModel.fromJson(recipeJson))),
        ingredientRequiredList = List<MenuIngredient>.from(
          (json['ingredient_required'] ?? []).map(
            (recipeJson) => MenuIngredient.fromJson(recipeJson),
          ),
        ),
        ingredientOptionalList = List<MenuIngredient>.from(
          (json['ingredient_optional'] ?? []).map(
            (recipeJson) => MenuIngredient.fromJson(recipeJson),
          ),
        );

  MenuModel.fromSharedJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        way = json['way'],
        ingredientDescriptionText = json['ingredientDescriptionText'],
        url = json['url'],
        recipe = List<RecipeModel>.from(json['recipe']
            .map((recipeJson) => RecipeModel.fromJson(recipeJson))),
        ingredientRequiredList =
            List<MenuIngredient>.from((json['ingredientRequired'] ?? []).map(
          (recipeJson) => MenuIngredient.fromJson(recipeJson),
        )),
        ingredientOptionalList = List<MenuIngredient>.from(
          (json['ingredientOptional'] ?? []).map(
            (recipeJson) => MenuIngredient.fromJson(recipeJson),
          ),
        );

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'way': way,
      'ingredientDescriptionText': ingredientDescriptionText,
      'url': url,
      'recipe': recipe,
      'ingredientRequiredList': ingredientRequiredList,
      'ingredientOptionalList': ingredientOptionalList,
    };
  }
}

class RecipeModel {
  final text, url; // 서버에서 가끔 Null 날라와서 일단 Final 처리

  RecipeModel({
    required this.text,
    required this.url,
  });

  RecipeModel.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        url = json['url'];

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'url': url,
    };
  }
}

class MenuIngredient {
  int id;
  String iconName, name;

  MenuIngredient({
    required this.id,
    required this.name,
    required this.iconName,
  });

  MenuIngredient.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        iconName = json['icon_name'];
}

class SimplifiedMenu {
  int id;
  String name, url;
  bool isLiked;

  SimplifiedMenu({
    required this.id,
    required this.name,
    required this.url,
    required this.isLiked,
  });

  SimplifiedMenu copyWith({
    int? id,
    String? name,
    String? url,
    bool? isLiked,
  }) {
    return SimplifiedMenu(
      id: id ?? this.id,
      name: name ?? this.name,
      url: url ?? this.url,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  SimplifiedMenu.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        url = json['url'],
        isLiked = false;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'isLiked': false,
    };
  }
}

class IngredientUtil {
  static String nameToKeepState(String name) {
    if (name == '냉장') return 'refrigerate';
    if (name == '냉동') return 'freezing';
    if (name == '실온') return 'roomTemperature';
    return 'refrigerate';
  }
}

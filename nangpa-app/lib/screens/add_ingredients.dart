import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nangpa/models/ingredient_model.dart';
import 'package:nangpa/services/api_service.dart';
import 'package:nangpa/utils/ingredient.utils.dart';
import 'package:nangpa/widgets/ingredient.dart';
import 'package:nangpa/widgets/input.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddIngredients extends StatefulWidget {
  final Function onModalClose;
  final String activeTab;

  const AddIngredients(
      {Key? key, required this.onModalClose, required this.activeTab})
      : super(key: key);

  @override
  State<AddIngredients> createState() => _AddIngredientsState();
}

class _AddIngredientsState extends State<AddIngredients> {
  final Future<IngredientListModel?> ingredientList =
      ApiService().getIngredients();
  String? selectedCategory; // 선택된 카테고리 이름
  bool isFindedState = false; // 찾으려는 시도를 했는지 안했는지
  List<IngredientModel> findedIngredientList = [];
  List<IngredientModel> selectedIngredients = [];

  // 홈 화면에 보여줄 냉장고 재료 리스트.
  late SharedPreferences sharedPrefs;

  // 재료 저장하기
  saveSharedPrefs(BuildContext context) async {
    sharedPrefs = await SharedPreferences.getInstance();

    final addedIngredientListJson =
        sharedPrefs.getStringList('addedIngredientList');
    List<IngredientModel> addedIngredientList = addedIngredientListJson != null
        ? addedIngredientListJson
            .map((json) => IngredientModel.fromSharedJson(jsonDecode(json)))
            .toList()
        : [];

    final now = DateTime.now();

    for (final ingredient in selectedIngredients) {
      final existingIndex = addedIngredientList.indexWhere(
          (addedIngredient) => addedIngredient.name == ingredient.name);
      if (existingIndex >= 0) {
        final existingIngredient = addedIngredientList[existingIndex];
        existingIngredient.createdAt = now;
        existingIngredient.expiryAt =
            now.add(Duration(days: existingIngredient.expiryDate));
        existingIngredient.keepState = ingredient.keepState;
      } else {
        final newIngredient = IngredientModel(
          id: ingredient.id,
          name: ingredient.name,
          iconName: ingredient.iconName,
          category: ingredient.category,
          createdAt: now,
          expiryAt: now.add(Duration(days: ingredient.expiryDate)),
          expiryDate: ingredient.expiryDate,
          keepState: ingredient.keepState,
        );
        addedIngredientList.add(newIngredient);
      }
    }

    final jsonStringList = addedIngredientList
        .map((ingredient) => jsonEncode(ingredient.toJson()))
        .toList();

    await sharedPrefs.setStringList('addedIngredientList', jsonStringList);
    _closeModal(context);
  }

  // 창 닫고 홈 화면 이동
  void _closeModal(BuildContext context) {
    Navigator.pop(context);
    widget.onModalClose();
  }

  // 재료 선택 했을 때 동작
  void _onIngredientSelected(IngredientModel recievedIngredient) {
    // 현재 서버에서 넘겨주는 값에 keepState가 없으므로 냉장 상태로 기본 초기화가 된다.
    // 선택된 버튼에 따라서 냉장, 냉동, 실온이 동작하려면 선택되는 값을 변형시켜서 넣어야한다.
    final modifyKeepStateRecievedIngredient = recievedIngredient.copyWith(
        keepState: IngredientUtil.nameToKeepState(widget.activeTab));
    setState(() {
      if (selectedIngredients
          .any((list) => list.id == modifyKeepStateRecievedIngredient.id)) {
        selectedIngredients.removeWhere(
            (list) => list.id == modifyKeepStateRecievedIngredient.id);
      } else {
        selectedIngredients.add(modifyKeepStateRecievedIngredient);
      }
    });
  }

  void _findSimilarIngredients(
      String query, List<IngredientModel> ingredientList) {
    // init
    findedIngredientList = [];
    isFindedState = query == '' ? false : true;

    final normalizedQuery = query.toLowerCase();
    final matches = ingredientList.where((ingredient) {
      final normalizedIngredientName = ingredient.name.toLowerCase();
      return normalizedIngredientName.contains(normalizedQuery);
    }).toList();

    setState(() {
      findedIngredientList = matches;
    });
  }

  void _onCliearInput() {
    setState(() {
      isFindedState = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: selectedIngredients.isNotEmpty
            ? SizedBox(
                height: 56,
                width: 216,
                child: FloatingActionButton.extended(
                  onPressed: () {
                    saveSharedPrefs(context);
                  },
                  label: const Text(
                    '재료 추가하기',
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: 'EF_watermelonSalad',
                      letterSpacing: -0.2,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(300),
                  ),
                  backgroundColor: const Color.fromRGBO(28, 176, 121, 1),
                  foregroundColor: Colors.white,
                  elevation: 6,
                  highlightElevation: 12,
                  disabledElevation: 0,
                  isExtended: true,
                ),
              )
            : null,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Center(
          child: Container(
            height: MediaQuery.of(context).size.height * 0.9,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: 24, bottom: 11, left: 36, right: 36),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Expanded(
                            child: Center(
                              child: Text(
                                '냉장고 재료 추가하기',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'EF_watermelonSalad',
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _closeModal(context);
                            },
                            child: const Icon(
                              Icons.close,
                              size: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      thickness: 1.0,
                      color: Color(0xffE9E9E9),
                    )
                  ],
                ),
                Flexible(
                  child: FutureBuilder(
                    future: ingredientList,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        selectedCategory ??=
                            snapshot.data!.categorisedList.keys.first;
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 22),
                              child: Input(
                                onSubmit: (String query) {
                                  _findSimilarIngredients(
                                      query, snapshot.data!.ingredientList);
                                },
                                onChange: (String query) {
                                  _findSimilarIngredients(
                                      query, snapshot.data!.ingredientList);
                                },
                                onClear: _onCliearInput,
                                placeholder: '재료를 검색해보세요.',
                              ),
                            ),
                            makeCategoryBtns(snapshot),
                            isFindedState
                                ? Expanded(
                                    child: findIngredientList(
                                      findedIngredientList,
                                      selectedIngredients,
                                      _onIngredientSelected,
                                    ),
                                  )
                                : Expanded(
                                    child: makeIngredientList(
                                      snapshot,
                                      _onIngredientSelected,
                                      selectedIngredients,
                                      selectedCategory,
                                    ),
                                  ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }
                      if (snapshot.hasError || snapshot.data == null) {
                        return const Center(
                          child: Text(
                            '재료를 불러오는데 실패했습니다.\n 다시 시도해주세요.',
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  SingleChildScrollView makeCategoryBtns(
      AsyncSnapshot<IngredientListModel?> snapshot) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int index = 0;
              index < snapshot.data!.categorisedList.length;
              index++)
            Builder(
              builder: (BuildContext context) {
                String category =
                    snapshot.data!.categorisedList.keys.elementAt(index);
                bool isSelected = selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5.0),
                  child: OutlinedButton(
                    onPressed: () {
                      // 버튼이 클릭되면 수행할 작업
                      setState(() {
                        selectedCategory = category;
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isSelected ? Colors.white : const Color(0xFFC2C2C2),
                      backgroundColor:
                          isSelected ? const Color(0xFF1CB079) : Colors.white,
                      side: BorderSide(
                        color: isSelected
                            ? Colors.transparent
                            : const Color(0xFFE6E6E6),
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      category,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

SingleChildScrollView findIngredientList(
    List<IngredientModel> findedIngredientList,
    List<IngredientModel> selectedIngredients,
    Function(IngredientModel) onIngredientSelected) {
  return SingleChildScrollView(
    child: findedIngredientList.isNotEmpty
        ? Padding(
            padding: const EdgeInsets.all(.0),
            child: Wrap(
              children: [
                ...findedIngredientList
                    .map(
                      (list) => Ingredient(
                          iconName: list.iconName,
                          name: list.name,
                          id: list.id,
                          checked: selectedIngredients
                              .any((sel) => sel.id == list.id),
                          onTap: () {
                            onIngredientSelected(list);
                          }),
                    )
                    .toList(),
              ],
            ),
          )
        : const SizedBox(
            height: 500,
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('찾으시는 재료가 없습니다.'),
              ),
            ),
          ),
  );
}

SingleChildScrollView makeIngredientList(
    AsyncSnapshot<IngredientListModel?> snapshot,
    Function(IngredientModel) onIngredientSelected,
    List<IngredientModel> selectedIngredients,
    String? selectedCategory) {
  return SingleChildScrollView(
    child: Column(
      children: snapshot.data!.categorisedList.entries
          .where((entry) => entry.key == selectedCategory)
          .map((category) => Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Wrap(
                      children: [
                        ...category.value
                            .map(
                              (list) => Ingredient(
                                  iconName: list.iconName,
                                  name: list.name,
                                  id: list.id,
                                  checked: selectedIngredients
                                      .any((sel) => sel.id == list.id),
                                  onTap: () {
                                    onIngredientSelected(list);
                                  }),
                            )
                            .toList(),
                      ],
                    ),
                  ),
                ],
              ))
          .toList(),
    ),
  );
}

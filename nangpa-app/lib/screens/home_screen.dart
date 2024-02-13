import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nangpa/models/ingredient_model.dart';
import 'package:nangpa/screens/add_ingredients.dart';
import 'package:nangpa/screens/ingredient_detail.dart';
import 'package:nangpa/screens/recommend_recipe.dart';
import 'package:nangpa/utils/date_utils.dart';
import 'package:nangpa/widgets/ingredient.dart';
import 'package:nangpa/widgets/nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/pill_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isEnabledRecommendBtn = false;
  Future<List<IngredientModel>> _addedIngredientListFuture = _loadData();
  String activeTab = '냉장';

  static Future<List<IngredientModel>> _loadData() async {
    final sharedPrefs = await SharedPreferences.getInstance();
    final addedIngredientListJson =
        sharedPrefs.getStringList('addedIngredientList');

    return addedIngredientListJson != null
        ? addedIngredientListJson
            .map((json) => IngredientModel.fromSharedJson(jsonDecode(json)))
            .toList()
        : [];
  }

  void _refreshData() {
    setState(() {
      _addedIngredientListFuture = _loadData();
    });
  }

  // 재료 추가
  void _onClickAddIngredientBtn(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      builder: (BuildContext context) => AddIngredients(
        onModalClose: () {
          _refreshData();
        },
        activeTab: activeTab,
      ),
    );
  }

  // 선택된 재료 자세히 보기
  void _onClickAddedIngredient(
    BuildContext context,
    IngredientModel ingredient,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30.0),
          topRight: Radius.circular(30.0),
        ),
      ),
      builder: (BuildContext context) => IngredientDetail(
        ingredient: ingredient,
        onModalClose: () {
          _refreshData();
        },
      ),
    );
  }

  String _calcIngredientStatus(IngredientModel ingredient) {
    // good(양호 7일 이상 남았을 때),warning(경고 D-7 ~ D-4), danger(위험 D-3 이하)
    final int dDay = DateUtil.daysLeft(ingredient.expiryAt);
    if (dDay > 7) return 'good';
    if (dDay > 3) return 'warning';
    return 'danger';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: const NavBar(),
      backgroundColor: Colors.white,
      floatingActionButton: floatBtn(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
            padding: const EdgeInsets.only(left: 30.0),
            iconSize: 30.0,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                _onClickAddIngredientBtn(context);
              },
              padding: const EdgeInsets.only(right: 30.0),
              iconSize: 30.0,
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16, horizontal: 30),
            child: Text(
              '우리집 냉장고를\n확인해볼까요',
              style: TextStyle(
                fontFamily: 'EF_watermelonSalad',
                fontSize: 30,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 30, top: 4),
            child: Row(
              children: [
                PillButton(
                  '냉장',
                  onPressed: () {
                    setState(() {
                      if (activeTab != '냉장') activeTab = '냉장';
                    });
                  },
                  isActive: activeTab == '냉장',
                ),
                const SizedBox(
                  width: 10,
                ),
                PillButton(
                  '냉동',
                  onPressed: () {
                    setState(() {
                      if (activeTab != '냉동') activeTab = '냉동';
                    });
                  },
                  isActive: activeTab == '냉동',
                ),
                const SizedBox(
                  width: 10,
                ),
                PillButton(
                  '실온',
                  onPressed: () {
                    setState(() {
                      if (activeTab != '실온') activeTab = '실온';
                    });
                  },
                  isActive: activeTab == '실온',
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 15,
          ),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 300,
            child: FutureBuilder<List<IngredientModel>>(
                future: _addedIngredientListFuture,
                builder: (BuildContext context,
                    AsyncSnapshot<List<IngredientModel>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error fetching data'));
                  } else if (snapshot.data?.isEmpty ?? true) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width / 3,
                          height: MediaQuery.of(context).size.width / 3,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color.fromRGBO(217, 217, 217, 0.3),
                                  ),
                                ),
                              ),
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: SvgPicture.asset(
                                    'assets/icons/ingredients/icon-refrigerator-grey.svg',
                                    width: 70,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            '냉장고가 비어 있어요!\n상단의 + 추가 버튼을 눌러서\n추가해보세요',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: 'EF_watermelonSalad',
                                fontSize: 20,
                                height: 1.7,
                                color: Color.fromRGBO(164, 164, 164, 1)),
                          ),
                        )
                      ],
                    );
                  } else {
                    // 보관된 재료 뿌리기.
                    return printIngredients(snapshot, context);
                  }
                }),
          )
        ],
      ),
    );
  }

  FutureBuilder floatBtn(BuildContext context) {
    return FutureBuilder<List<IngredientModel>>(
      future: _addedIngredientListFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.data?.isEmpty ?? true) {
          return const SizedBox();
        } else {
          final addedIngredientList = snapshot.data!;
          isEnabledRecommendBtn = addedIngredientList.isNotEmpty;
          return SizedBox(
            height: 56,
            width: 216,
            child: FloatingActionButton.extended(
              onPressed: isEnabledRecommendBtn
                  ? () {
                      final ingredientNameList =
                          addedIngredientList.map((e) => e.name).toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecommendRecipe(
                            ingredientNameList: ingredientNameList,
                          ),
                        ),
                      );
                    }
                  : null,
              label: const Text(
                '레시피 추출하기',
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
          );
        }
      },
    );
  }

  ListView printIngredients(
      AsyncSnapshot<List<IngredientModel>> snapshot, BuildContext context) {
    final ingredientsList = snapshot.data!;
    Map<String, List<IngredientModel>> filteredIngredientList = {};
    for (var element in ingredientsList) {
      if (filteredIngredientList[element.keepState] is List) {
        filteredIngredientList[element.keepState]!.add(element);
      } else {
        filteredIngredientList[element.keepState] = [element];
      }
    }
    return ListView(children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (activeTab == '실온' &&
                filteredIngredientList['roomTemperature'] != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  children: filteredIngredientList['roomTemperature']!
                      .map(
                        (list) => Ingredient(
                            id: list.id,
                            iconName: list.iconName,
                            name: list.name,
                            onTap: () {
                              _onClickAddedIngredient(context, list);
                            },
                            ingredientKeepStatus: _calcIngredientStatus(list)),
                      )
                      .toList(),
                ),
              ),
            if (activeTab == '냉장' &&
                filteredIngredientList['refrigerate'] != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  children: filteredIngredientList['refrigerate']!
                      .map(
                        (list) => Ingredient(
                          id: list.id,
                          iconName: list.iconName,
                          name: list.name,
                          onTap: () {
                            _onClickAddedIngredient(context, list);
                          },
                          ingredientKeepStatus: _calcIngredientStatus(list),
                        ),
                      )
                      .toList(),
                ),
              ),
            if (activeTab == '냉동' && filteredIngredientList['freezing'] != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Wrap(
                  children: filteredIngredientList['freezing']!
                      .map(
                        (list) => Ingredient(
                            id: list.id,
                            iconName: list.iconName,
                            name: list.name,
                            onTap: () {
                              _onClickAddedIngredient(context, list);
                            },
                            ingredientKeepStatus: _calcIngredientStatus(list)),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    ]);
  }
}

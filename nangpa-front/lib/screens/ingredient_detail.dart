import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nangpa/models/ingredient_model.dart';
import 'package:nangpa/utils/date_utils.dart';
import 'package:nangpa/widgets/button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IngredientDetail extends StatefulWidget {
  IngredientModel ingredient;
  final Function onModalClose;

  IngredientDetail({
    super.key,
    required this.ingredient,
    required this.onModalClose,
  });

  @override
  State<IngredientDetail> createState() => _IngredientDetailState();
}

class _IngredientDetailState extends State<IngredientDetail> {
  late DateTime _selectedDate; // 변경되는 소비기간
  late String _selectedKeepState; // 변경되는 보관 방법 (냉동, 냉장, 실온)
  bool isOpen = false; // 보관 방법 선택 dialog의 메뉴 리스트가 열린지 안열린지 상태
  OverlayEntry? _overlayEntry;
  final LayerLink _layerLink = LayerLink();

  final List<Map<String, String>> storeItems = [
    {'냉장': 'refrigerate'},
    {'냉동': 'freezing'},
    {'실온': 'roomTemperature'}
  ];

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.ingredient.expiryAt;
    _selectedKeepState = widget.ingredient.keepState;
  }

  // 날짜
  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  bool _isDifferentDate(DateTime date1, DateTime date2) {
    return date1.year != date2.year ||
        date1.month != date2.month ||
        date1.day != date2.day;
  }

  // 저장 버튼 사용 가능한지 체크하는 함수
  bool checkSaveBtnEnabled() {
    return _isDifferentDate(_selectedDate, widget.ingredient.expiryAt) ||
        _selectedKeepState != widget.ingredient.keepState;
  }

  void _save() async {
    IngredientModel modifiedIngredient = widget.ingredient;
    modifiedIngredient.keepState = _selectedKeepState;
    modifiedIngredient.expiryAt = _selectedDate;

    final sharedPrefs = await SharedPreferences.getInstance();
    final addedIngredientListJson =
        sharedPrefs.getStringList('addedIngredientList');
    if (addedIngredientListJson == null) return;

    final updatedList = addedIngredientListJson
        .map((json) => IngredientModel.fromSharedJson(jsonDecode(json)))
        .map((ingredient) {
      if (ingredient.id == modifiedIngredient.id) {
        // id가 일치하면 업데이트된 IngredientModel을 반환합니다.
        return modifiedIngredient;
      }
      return ingredient;
    }).toList();

    final jsonStringList = updatedList
        .map((ingredient) => jsonEncode(ingredient.toJson()))
        .toList();

    await sharedPrefs.setStringList('addedIngredientList', jsonStringList);
    onCloseModal();
  }

  String formatDate(DateTime date) {
    return '${date.year}년 ${date.month.toString().padLeft(2, '0')}월 ${date.day.toString().padLeft(2, '0')}일';
  }

  String formatKeepState(String keepState) {
    if (keepState == 'refrigerate') return '냉장 보관';
    if (keepState == 'freezing') return '냉동 보관';
    return '실온 보관';
  }

  void removeItem() async {
    // 해당 목록 삭제
    final sharedPrefs = await SharedPreferences.getInstance();
    final addedIngredientListJson =
        sharedPrefs.getStringList('addedIngredientList') ?? [];

    final addedList = addedIngredientListJson != null
        ? addedIngredientListJson
            .map((json) => IngredientModel.fromSharedJson(jsonDecode(json)))
            .toList()
        : [];
    addedList.removeWhere((item) => item.id == widget.ingredient.id);

    final jsonStringList =
        addedList.map((ingredient) => jsonEncode(ingredient.toJson())).toList();

    await sharedPrefs.setStringList('addedIngredientList', jsonStringList);

    onCloseModal();
  }

  onCloseModal() {
    Navigator.pop(context);
    widget.onModalClose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 410,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        bottomNavigationBar: SizedBox(
          height: 70,
          child: Button(
            onPressed: () {
              _save();
            },
            isEnabled: checkSaveBtnEnabled(),
            btnText: "저장",
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Row(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.ingredient.name,
                          style: const TextStyle(
                            fontFamily: 'EF_watermelonSalad',
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        printDaysLeft()
                      ],
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          removeItem();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: const [
                            Text(
                              '재료 삭제하기',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color.fromRGBO(136, 136, 136, 1),
                              ),
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: MediaQuery.of(context).size.width - 60,
                  height: 58,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(236, 236, 236, 1),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Text(
                              '추가된 날짜',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 8),
                          child: Text(
                            formatDate(widget.ingredient.createdAt),
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Container(
                  width: MediaQuery.of(context).size.width - 60,
                  height: 58,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(236, 236, 236, 1),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18, right: 11),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '소비기한 마감일',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: GestureDetector(
                            onTap: _showDatePicker,
                            child: Row(
                              children: [
                                Text(
                                  formatDate(_selectedDate),
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                  ),
                                ),
                                const Icon(Icons.chevron_right)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Container(
                  width: MediaQuery.of(context).size.width - 60,
                  height: 58,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: const Color.fromRGBO(236, 236, 236, 1),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 18.0, right: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '보관 방법',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return StatefulBuilder(builder: (
                                  BuildContext context,
                                  StateSetter setState,
                                ) {
                                  return storeDropDown(setState);
                                });
                              },
                            );
                          },
                          child: Row(
                            children: [
                              Text(
                                formatKeepState(_selectedKeepState),
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                              const Icon(Icons.chevron_right)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _createOverlay() {
    if (_overlayEntry == null) {
      _overlayEntry = _customDropdown();
      Overlay.of(context).insert(_overlayEntry!);
    }
  }

  // 드롭다운 해제.
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _customDropdown() {
    return OverlayEntry(
      maintainState: true,
      builder: (context) => Positioned(
        width: 194,
        child: CompositedTransformFollower(
          link: _layerLink,
          offset: const Offset(0, 55),
          child: Container(
            width: 194,
            height: 144,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color.fromRGBO(28, 176, 121, 1),
              ),
            ),
            child: Column(
              children: storeItems.map((a) {
                int idx = storeItems.indexOf(a);
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedKeepState = a.values.first;
                        });
                        _removeOverlay();
                        isOpen = false;
                        Navigator.of(context).pop();
                      },
                      child: SizedBox(
                        width: 194,
                        height: 46,
                        child: Text(
                          a.keys.first,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                            decoration: TextDecoration.none,
                            height: 2.2,
                          ),
                        ),
                      ),
                    ),
                    if (idx != storeItems.length - 1)
                      const Divider(
                        height: 1,
                        color: Color.fromRGBO(233, 233, 233, 1),
                        thickness: 1,
                      )
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }

  WillPopScope storeDropDown(StateSetter setState) {
    return WillPopScope(
      onWillPop: () async {
        _removeOverlay();
        isOpen = false;
        return true;
      },
      child: AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.0),
        ),
        title: const Text(
          '보관 방법 선택',
          style: TextStyle(
            fontFamily: 'EF_watermelonSalad',
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        content: Padding(
          padding: const EdgeInsets.only(
            top: 10.0,
            bottom: 15.0,
            left: 20,
            right: 20,
          ),
          child: GestureDetector(
            onTap: () {
              setState(() {
                if (!isOpen) _createOverlay();
                if (isOpen) _removeOverlay();
                isOpen = !isOpen;
              });
            },
            child: CompositedTransformTarget(
              link: _layerLink,
              child: Container(
                width: 194.0,
                height: 46.0,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isOpen
                        ? const Color.fromRGBO(28, 176, 121, 1)
                        : const Color.fromRGBO(236, 236, 236, 1),
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const SizedBox(width: 30),
                    Text(
                      formatKeepState(_selectedKeepState).substring(0, 2),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    if (isOpen)
                      const Icon(
                        Icons.arrow_drop_up,
                        size: 30,
                        color: Color.fromRGBO(28, 176, 121, 1),
                      )
                    else
                      const Icon(
                        Icons.arrow_drop_down,
                        size: 30,
                        color: Color.fromRGBO(129, 138, 146, 1),
                      )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Padding printDaysLeft() {
    Color getDDayColor(int leftDay) {
      if (leftDay > 8) {
        return const Color.fromRGBO(28, 176, 121, 1);
      }
      if (leftDay > 7) {
        return const Color.fromRGBO(255, 107, 0, 1);
      }
      return Colors.red;
    }

    Color getDDayBgColor(int leftDay) {
      if (leftDay > 8) {
        return const Color.fromRGBO(231, 249, 225, 1);
      }
      if (leftDay > 7) {
        return const Color.fromRGBO(255, 215, 168, 0.4);
      }
      return Colors.red.shade100;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 2.0),
      child: Container(
        width: 53,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: getDDayBgColor(DateUtil.daysLeft(widget.ingredient.expiryAt)),
        ),
        child: Text(
          "D-${DateUtil.daysLeft(widget.ingredient.expiryAt)}",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: getDDayColor(DateUtil.daysLeft(widget.ingredient.expiryAt)),
          ),
        ),
      ),
    );
  }
}

/*
TextButton(
onPressed: () {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('보관 방법 선택'),
        content: DropdownButton<String>(
          value: _selectedKeepState,
          items: [
            {'냉장': 'refrigerate'},
            {'냉동': 'freezing'},
            {'실온': 'roomTemperature'}
          ].map<DropdownMenuItem<String>>(
              (Map<String, String> item) {
            final String label = item.keys.first;
            final String value =
                item.values.first;
            return DropdownMenuItem<String>(
              value: value,
              child: Text(label),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedKeepState = newValue!;
            });
            Navigator.of(context).pop();
          },
        ),
      );
    },
  );
},
child: const SizedBox()),
*/
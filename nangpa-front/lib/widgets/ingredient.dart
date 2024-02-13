import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Ingredient extends StatefulWidget {
  final String iconName, name;
  final int id;
  final bool checked;
  final VoidCallback? onTap;
  final String
      ingredientKeepStatus; // good(양호 7일 이상 남았을 때),warning(경고 D-7 ~ D-4), danger(위험 D-3 이하)

  const Ingredient({
    super.key,
    required this.iconName,
    required this.name,
    required this.id,
    this.checked = false,
    this.onTap,
    this.ingredientKeepStatus = 'good',
  });

  @override
  State<Ingredient> createState() => _IngredientState();
}

class _IngredientState extends State<Ingredient> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 12.0),
        child: Container(
          width: (MediaQuery.of(context).size.width - 100) / 2,
          height: 140,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
                color: widget.checked
                    ? const Color.fromRGBO(28, 176, 121, 1)
                    : const Color.fromRGBO(240, 240, 240, 1),
                style: BorderStyle.solid),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    widget.iconName != ''
                        ? SvgPicture.asset(
                            'assets/icons/ingredients/${widget.iconName}.svg',
                            semanticsLabel: widget.name,
                            height: 50,
                            width: 50,
                          )
                        : SvgPicture.asset(
                            'assets/icons/ingredients/no-image.svg',
                            semanticsLabel: widget.name,
                            height: 50,
                            width: 50,
                          ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      widget.name,
                      style: const TextStyle(
                        fontFamily: 'EF_watermelonSalad',
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                if (widget.ingredientKeepStatus == 'warning')
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.yellow,
                      ),
                    ),
                  ),
                if (widget.ingredientKeepStatus == 'danger')
                  Positioned(
                    top: 3,
                    right: 3,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

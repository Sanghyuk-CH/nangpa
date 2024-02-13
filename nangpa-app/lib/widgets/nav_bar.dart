import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: ListView(
        children: [
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 30, top: 10, bottom: 50),
                  child: Image.asset(
                    'assets/icons/ingredients/icon-app.png',
                    height: 76,
                    width: 76,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SvgPicture.asset(
                'assets/icons/ingredients/icon-home.svg',
                semanticsLabel: 'cow',
                height: 26,
                width: 26,
              ),
            ),
            title: const Padding(
              padding: EdgeInsets.only(left: 2.0, top: 4),
              child: Text(
                '홈',
                style: TextStyle(
                  fontFamily: 'EF_watermelonSalad',
                  fontSize: 20,
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/');
            },
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SvgPicture.asset(
                'assets/icons/ingredients/icon-book.svg',
                semanticsLabel: 'cow',
                height: 24,
                width: 24,
              ),
            ),
            title: const Padding(
              padding: EdgeInsets.only(left: 2.0, top: 4),
              child: Text(
                '레시피 보러가기',
                style: TextStyle(
                  fontFamily: 'EF_watermelonSalad',
                  fontSize: 20,
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/recipes');
            },
          ),
          ListTile(
            leading: const Padding(
                padding: EdgeInsets.only(left: 16), child: Icon(Icons.people)),
            title: const Padding(
              padding: EdgeInsets.only(left: 2.0, top: 4),
              child: Text(
                '커뮤니티',
                style: TextStyle(
                  fontFamily: 'EF_watermelonSalad',
                  fontSize: 20,
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/community');
            },
          ),
          ListTile(
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: SvgPicture.asset(
                'assets/icons/ingredients/icon-like.svg',
                semanticsLabel: 'cow',
                height: 26,
                width: 26,
              ),
            ),
            title: const Padding(
              padding: EdgeInsets.only(left: 2.0, top: 4),
              child: Text(
                '찜목록',
                style: TextStyle(
                  fontFamily: 'EF_watermelonSalad',
                  fontSize: 20,
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
          ListTile(
            leading: const Padding(
              padding: EdgeInsets.only(left: 16),
              child: Icon(Icons.person),
            ),
            title: const Padding(
              padding: EdgeInsets.only(left: 2.0, top: 4),
              child: Text(
                '프로필',
                style: TextStyle(
                  fontFamily: 'EF_watermelonSalad',
                  fontSize: 20,
                ),
              ),
            ),
            onTap: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
    );
  }
}

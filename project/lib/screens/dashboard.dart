import 'package:flutter/material.dart';
import 'sections/home.dart';
import 'sections/live.dart';
import 'sections/notif.dart';
import 'sections/profile.dart';
import 'cart.dart';
import 'chatlist.dart';

class DashboardScreen extends StatefulWidget {
  final dynamic user;
  final int selectInitialIndex;
  const DashboardScreen({required this.user, this.selectInitialIndex = 0, super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  final TextEditingController search = TextEditingController(text: "");
  final FocusNode searchFocusNode = FocusNode();
  List<Widget>? screens;
  late List<Widget> _dashboardWidgets;
  @override
  void initState() {
    super.initState();
    setState(() {
      _selectedIndex = widget.selectInitialIndex;
    });

    screens = [
      Focus(
        focusNode: searchFocusNode,
        child: TextField(
          controller: search,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: const TextStyle(color: Colors.white),
            prefixIcon: const Icon(Icons.search, color: Colors.white),
            filled: true,
            fillColor: Colors.white30,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ),
      const Text(
        'Live Stream',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      const Text(
        'Notification',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      const Text(
        'Profile',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
    ];

    _updateDashboardWidgets();
    search.addListener(() {
      setState(() {
        _updateDashboardWidgets();
      });
    });
  }

  void _updateDashboardWidgets() {
    setState(() {
      _dashboardWidgets = [
        HomeDashboard(
          widget.user,
          search: search.text,
        ),
        LiveDashboard(widget.user),
        NotificationDashboard(widget.user),
        ProfileDashboard(widget.user),
      ];
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.pink,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: screens![_selectedIndex]),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CartScreen(widget.user)),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.chat, color: Colors.white),
                  onPressed: () {
                    if (widget.user['isSeller']) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => ChatListScreen(widget.user)));
                    } else {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChatDetailScreen(userId: widget.user['id'], partnerId: '1')));
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _dashboardWidgets[_selectedIndex],
          ),
          Container(
            decoration: const BoxDecoration(
              color: Colors.pink,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white70,
              backgroundColor: Colors.transparent,
              elevation: 0,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.live_tv),
                  label: 'Live',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.notifications),
                  label: 'Notifications',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.account_circle),
                  label: 'Profile',
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

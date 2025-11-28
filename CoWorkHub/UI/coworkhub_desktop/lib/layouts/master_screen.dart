import 'package:coworkhub_desktop/main.dart';
import 'package:coworkhub_desktop/screens/reservation_screen.dart';
import 'package:coworkhub_desktop/screens/users_screen.dart';
import 'package:coworkhub_desktop/screens/working_space_screen.dart';
import 'package:flutter/material.dart';

class MasterScreen extends StatefulWidget {
  const MasterScreen({super.key});

  @override
  State<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends State<MasterScreen> {
  int _selectedIndex = 0;
  late Widget _currentChild;
  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const Center(child: Text('Dashboard Page')),
      UsersScreen(
        onChangeScreen: (newScreen) {
          changeScreen(newScreen);
        },
      ),
      WorkingSpacesScreen(
        onChangeScreen: (newScreen) {
          changeScreen(newScreen);
        },
      ),
      ReservationScreen(onChangeScreen: (newScreen) => changeScreen(newScreen)),
    ];

    _currentChild = _pages[_selectedIndex];
  }

  // @override
  // void initState() {
  //   super.initState();
  //   _currentChild = _pages[_selectedIndex];
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 200,
            color: const Color.fromARGB(255, 76, 91, 116),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 70,
                  padding: const EdgeInsets.only(left: 25),
                  alignment: Alignment.centerLeft,
                  child: const Text(
                    "Admin panel",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Divider(color: Colors.white24, height: 1),

                // Menu list
                _buildMenuItem(
                  index: 0,
                  icon: Icons.dashboard,
                  label: "Dashboard",
                ),
                _buildMenuItem(
                  index: 1,
                  icon: Icons.people,
                  label: "Korisnici",
                ),
                _buildMenuItem(
                  index: 2,
                  icon: Icons.apartment,
                  label: "Prostori",
                ),
                _buildMenuItem(
                  index: 3,
                  icon: Icons.calendar_month,
                  label: "Rezervacije",
                ),

                const Spacer(),

                // Logout button
                _buildMenuItem(
                  index: 99,
                  icon: Icons.logout,
                  label: "Logout",
                  isLogout: true,
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),

          // Main Content + Navbar
          Expanded(
            child: Column(
              children: [
                // TOP NAVBAR
                Container(
                  height: 55,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F7),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left title
                      Text(
                        getPageTitle(_selectedIndex),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      // Profile avatar
                      InkWell(
                        onTap: () {
                          // Ovdje ćeš kasnije otvoriti user details
                        },
                        child: CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.grey.shade300,
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),

                // PAGE CONTENT
                Expanded(
                  child: Container(color: Colors.white, child: _currentChild),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Menu item builder
  Widget _buildMenuItem({
    required int index,
    required IconData icon,
    required String label,
    bool isLogout = false,
  }) {
    bool selected = index == _selectedIndex;
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setHover) {
        return MouseRegion(
          onEnter: (_) => setHover(() => isHovered = true),
          onExit: (_) => setHover(() => isHovered = false),

          child: InkWell(
            onTap: () {
              if (isLogout) {
                _showLogoutDialog();
              } else {
                setState(() {
                  _selectedIndex = index;
                  _currentChild = _pages[_selectedIndex];
                });
              }
            },

            child: Container(
              height: 50,
              padding: const EdgeInsets.only(left: 20),
              color: isLogout
                  ? (isHovered ? const Color(0xFFB91C1C) : Colors.transparent)
                  : selected
                  ? const Color(0xFF1F2937)
                  : isHovered
                  ? const Color(0xFF334155)
                  : Colors.transparent,

              child: Row(
                children: [
                  Icon(
                    icon,
                    color: isLogout
                        ? (isHovered ? Colors.white : Colors.redAccent)
                        : selected
                        ? Colors.white
                        : Colors.white70,
                  ),
                  const SizedBox(width: 15),
                  Text(
                    label,
                    style: TextStyle(
                      color: isLogout
                          ? (isHovered ? Colors.white : Colors.redAccent)
                          : selected
                          ? Colors.white
                          : Colors.white70,
                      fontSize: 15,
                      fontWeight: selected || isLogout
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void changeScreen(Widget newChild) {
    setState(() {
      _currentChild = newChild;
    });
  }

  // Logout dialog
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Odjava"),
          content: const Text("Da li ste sigurni da želite izaći?"),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                );
              },
              child: const Text("Da"),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Ne"),
            ),
          ],
        );
      },
    );
  }

  // Page title resolver
  String getPageTitle(int index) {
    switch (index) {
      case 0:
        return "Dashboard";
      case 1:
        return "Korisnici";
      case 2:
        return "Prostori";
      case 3:
        return "Rezervacije";
      default:
        return "";
    }
  }
}

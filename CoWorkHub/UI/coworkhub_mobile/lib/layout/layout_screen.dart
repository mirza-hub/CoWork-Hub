import 'package:coworkhub_mobile/screens/history_reservation_screen.dart';
import 'package:coworkhub_mobile/screens/home_page.dart';
import 'package:coworkhub_mobile/screens/login_screen.dart';
import 'package:coworkhub_mobile/screens/profile_screen.dart';
import 'package:coworkhub_mobile/screens/reservation_screen.dart';
import 'package:flutter/material.dart';

class LayoutScreen extends StatefulWidget {
  const LayoutScreen({super.key});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen> {
  bool isSidebarOpen = false;
  bool isLoggedIn = true; // kasnije promijeni prema autentikaciji
  Widget _currentScreen = const HomePage(); // default screen
  String _activeItem = 'Početna';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Glavni ekran
          _currentScreen,

          // Menu button u gornjem lijevom uglu
          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.menu, size: 32),
              onPressed: () {
                setState(() {
                  isSidebarOpen = true;
                });
              },
            ),
          ),

          // Polu-transparent overlay
          if (isSidebarOpen)
            GestureDetector(
              onTap: () {
                setState(() {
                  isSidebarOpen = false;
                });
              },
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

          // Sidebar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            top: 0,
            bottom: 0,
            left: isSidebarOpen ? 0 : -300,
            width: 300,
            child: Material(
              elevation: 16,
              color: Colors.white,
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Close button
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            isSidebarOpen = false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // User info
                    if (isLoggedIn) ...[
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: NetworkImage(
                          'https://via.placeholder.com/150',
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Ime Prezime',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'email@example.com',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                    ] else
                      const SizedBox(height: 100), // prazan prostor
                    // Menu opcije
                    _buildSidebarItem(
                      'Početna',
                      Icons.home_outlined,
                      widgetToShow: const HomePage(),
                    ),
                    if (isLoggedIn) ...[
                      _buildSidebarItem(
                        'Pregled rezervacija',
                        Icons.calendar_today,
                        widgetToShow: const ReservationsScreen(),
                      ),
                      _buildSidebarItem(
                        'Historija rezervacija',
                        Icons.list_alt,
                        widgetToShow: const HistoryScreen(),
                      ),
                      _buildSidebarItem(
                        'Moj profil',
                        Icons.account_circle_outlined,
                        widgetToShow: const ProfileScreen(),
                      ),
                      const Spacer(),
                      _buildSidebarItem(
                        'Odjava',
                        Icons.logout_outlined,
                        widgetToShow: const HomePage(),
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTapExtra: () {
                          setState(() {
                            isLoggedIn = false;
                            _activeItem = 'Početna';
                          });
                        },
                      ),
                    ] else ...[
                      const Spacer(),
                      _buildSidebarItem(
                        'Prijavi se',
                        Icons.login,
                        widgetToShow: const LoginScreen(),
                        isButton: true,
                        onTapExtra: () {
                          setState(() {
                            isLoggedIn = true;
                            _activeItem = 'Početna';
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    String title,
    IconData icon, {
    required Widget widgetToShow,
    VoidCallback? onTapExtra,
    Color? iconColor,
    Color? textColor,
    bool isButton = false,
  }) {
    bool isActive = _activeItem == title;

    final bgColor = isActive ? Colors.blue.shade100 : Colors.transparent;

    Widget content = Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? Colors.black),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: textColor ?? Colors.black,
            ),
          ),
        ],
      ),
    );

    if (isButton) {
      // Za Prijava dugme stil
      content = SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            setState(() {
              _currentScreen = widgetToShow;
              _activeItem = 'Početna';
              isSidebarOpen = false;
            });
            if (onTapExtra != null) onTapExtra();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(title),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          if (!isButton) {
            setState(() {
              _currentScreen = widgetToShow;
              _activeItem = title;
              isSidebarOpen = false;
            });
            if (onTapExtra != null) onTapExtra();
          }
        },
        splashColor: Colors.red.shade200.withValues(),
        highlightColor: Colors.red.shade50,
        child: content,
      ),
    );
  }
}

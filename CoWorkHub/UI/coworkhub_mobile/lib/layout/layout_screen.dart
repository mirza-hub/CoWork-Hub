import 'package:coworkhub_mobile/models/extensions/user_image_extension.dart';
import 'package:coworkhub_mobile/providers/auth_provider.dart';
import 'package:coworkhub_mobile/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:coworkhub_mobile/models/user.dart';
import 'package:coworkhub_mobile/screens/login_screen.dart';
import 'package:coworkhub_mobile/screens/home_page.dart';
import 'package:coworkhub_mobile/screens/reservation_screen.dart';
import 'package:coworkhub_mobile/screens/history_reservation_screen.dart';
import 'package:coworkhub_mobile/screens/profile_screen.dart';
import 'package:provider/provider.dart';

_LayoutScreenState? _layoutScreenState;

class LayoutScreen extends StatefulWidget {
  final User? user;

  const LayoutScreen({super.key, this.user});

  @override
  State<LayoutScreen> createState() => _LayoutScreenState();
}

class _LayoutScreenState extends State<LayoutScreen>
    with WidgetsBindingObserver {
  late User? currentUser;
  bool isSidebarOpen = false;
  Widget _currentScreen = const HomePage();
  String _activeItem = "Početna";

  bool get isLoggedIn => currentUser != null;

  @override
  void initState() {
    super.initState();
    currentUser = widget.user;
    WidgetsBinding.instance.addObserver(this);
    // Setuj static referencu na state (samo za root LayoutScreen)
    _layoutScreenState = this;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLoginStatus();
    }
  }

  Future<void> _checkLoginStatus() async {
    if (AuthProvider.isSignedIn && AuthProvider.userId != null) {
      if (currentUser == null || currentUser!.usersId != AuthProvider.userId) {
        final provider = context.read<UserProvider>();
        try {
          final filter = {
            "UsersId": AuthProvider.userId,
            "IsUserRolesIncluded": true,
          };
          final result = await provider.get(filter: filter);

          if (result.resultList.isNotEmpty) {
            setState(() {
              currentUser = result.resultList.first;
            });
          }
        } catch (e) {
          debugPrint("Greška pri dohvaćanju korisnika: $e");
        }
      }
    }
  }

  Future<void> refreshLayout() async {
    if (AuthProvider.isSignedIn && AuthProvider.userId != null) {
      final provider = context.read<UserProvider>();
      try {
        final filter = {
          "UsersId": AuthProvider.userId,
          "IsUserRolesIncluded": true,
        };
        final result = await provider.get(filter: filter);

        if (result.resultList.isNotEmpty) {
          setState(() {
            currentUser = result.resultList.first;
          });
        }
      } catch (e) {
        debugPrint("Greška pri osvježavanju: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _currentScreen,

          Positioned(
            top: 40,
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.menu, size: 32),
              onPressed: () {
                setState(() => isSidebarOpen = true);
              },
            ),
          ),

          if (isSidebarOpen)
            GestureDetector(
              onTap: () => setState(() => isSidebarOpen = false),
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),

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
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() => isSidebarOpen = false),
                      ),
                    ),

                    const SizedBox(height: 16),

                    if (isLoggedIn) ...[
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue.shade200,
                        backgroundImage:
                            (currentUser!.getImageBytes() != null &&
                                currentUser!.getImageBytes()!.isNotEmpty)
                            ? MemoryImage(currentUser!.getImageBytes()!)
                            : null,
                        child: currentUser!.getImageBytes() == null
                            ? Text(
                                currentUser!.firstName[0] +
                                    currentUser!.lastName[0],
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "${currentUser!.firstName} ${currentUser!.lastName}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currentUser!.email,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                    ] else
                      const SizedBox(height: 100),

                    _menuItem(
                      title: "Početna",
                      icon: Icons.home_outlined,
                      page: const HomePage(),
                    ),

                    if (isLoggedIn) ...[
                      _menuItem(
                        title: "Pregled rezervacija",
                        icon: Icons.calendar_month_outlined,
                        page: const ReservationsScreen(),
                      ),
                      _menuItem(
                        title: "Historija rezervacija",
                        icon: Icons.history,
                        page: const HistoryScreen(),
                      ),
                      _menuItem(
                        title: "Moj profil",
                        icon: Icons.person_outline,
                        page: ProfileScreen(
                          onUserUpdated: (updatedUser) {
                            setState(() {
                              currentUser = updatedUser;
                            });
                          },
                        ),
                      ),
                      const Spacer(),
                      _menuItem(
                        title: "Odjava",
                        icon: Icons.logout,
                        iconColor: Colors.red,
                        textColor: Colors.red,
                        onTap: () {
                          setState(() {
                            currentUser = null;
                            AuthProvider.isSignedIn = false;
                            AuthProvider.userId = null;
                            _currentScreen = HomePage(key: UniqueKey());
                            _activeItem = "Početna";
                            isSidebarOpen = false;
                          });
                        },
                      ),
                    ] else ...[
                      const Spacer(),
                      _menuItem(
                        title: "Prijavi se",
                        icon: Icons.login,
                        isButton: true,
                        onTap: () async {
                          final user = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginScreen(),
                            ),
                          );

                          if (user != null && user is User) {
                            setState(() {
                              currentUser = user;
                              isSidebarOpen = false;
                            });
                          }
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

  Widget _menuItem({
    required String title,
    required IconData icon,
    Widget? page,
    VoidCallback? onTap,
    bool isButton = false,
    Color? iconColor,
    Color? textColor,
  }) {
    final bool isActive = _activeItem == title;

    if (isButton) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: onTap,
            icon: Icon(icon, color: Colors.white),
            label: Text(
              title,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ),
      );
    }

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: textColor,
        ),
      ),
      tileColor: isActive ? Colors.blue.shade100 : Colors.transparent,
      onTap: () {
        if (page != null) {
          setState(() {
            _currentScreen = page;
            _activeItem = title;
            isSidebarOpen = false;
          });
        }
        if (onTap != null) onTap();
      },
    );
  }
}

import 'package:coworkhub_desktop/screens/country_screen.dart';
import 'package:coworkhub_desktop/screens/resource_screen.dart';
import 'package:coworkhub_desktop/screens/space_type_screen.dart';
import 'package:flutter/material.dart';
import 'city_screen.dart';

class SettingsScreen extends StatelessWidget {
  final Function(Widget) onChangeScreen;

  const SettingsScreen({super.key, required this.onChangeScreen});

  void _onContainerTap(BuildContext context, String name) {
    if (name == "Gradovi") {
      onChangeScreen(CityScreen(onChangeScreen: onChangeScreen));
    } else if (name == "Države") {
      onChangeScreen(CountryScreen(onChangeScreen: onChangeScreen));
    } else if (name == "Resursi") {
      onChangeScreen(ResourceScreen(onChangeScreen: onChangeScreen));
    } else if (name == "Tipovi prostora") {
      onChangeScreen(SpaceTypeScreen(onChangeScreen: onChangeScreen));
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> items = [
      "Države",
      "Gradovi",
      "Resursi",
      "Tipovi prostora",
    ];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: items.map((item) {
          return _HoverContainer(
            label: item,
            onTap: () => _onContainerTap(context, item),
          );
        }).toList(),
      ),
    );
  }
}

// Hover kontenjer kao pre
class _HoverContainer extends StatefulWidget {
  final String label;
  final VoidCallback onTap;

  const _HoverContainer({required this.label, required this.onTap});

  @override
  State<_HoverContainer> createState() => _HoverContainerState();
}

class _HoverContainerState extends State<_HoverContainer> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(vertical: 8),
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: _isHovered ? Colors.blue.shade200 : Colors.blue.shade100,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

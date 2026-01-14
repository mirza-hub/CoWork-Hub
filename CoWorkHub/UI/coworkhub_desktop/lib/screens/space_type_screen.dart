import 'package:flutter/material.dart';
import 'settings_screen.dart';

class SpaceTypeScreen extends StatelessWidget {
  final Function(Widget) onChangeScreen;

  const SpaceTypeScreen({super.key, required this.onChangeScreen});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        children: [
          Stack(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  iconSize: 28,
                  onPressed: () {
                    onChangeScreen(
                      SettingsScreen(onChangeScreen: onChangeScreen),
                    );
                  },
                ),
              ),
              Center(
                child: Text(
                  "Tipovi prostora",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: [
                _buildContainer("Sala za sastanke"),
                _buildContainer("Open space"),
                _buildContainer("Privatna kancelarija"),
                _buildContainer("Coworking"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContainer(String name) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.teal.shade100,
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
          name,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

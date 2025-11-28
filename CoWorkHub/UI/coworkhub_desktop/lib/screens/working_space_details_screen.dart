import 'package:coworkhub_desktop/models/working_space.dart';
import 'package:coworkhub_desktop/screens/working_space_form_screen.dart';
import 'package:coworkhub_desktop/screens/working_space_screen.dart';
import 'package:flutter/material.dart';

class WorkingSpaceDetailsScreen extends StatefulWidget {
  final WorkingSpace space;
  final Function(Widget) onChangeScreen;

  const WorkingSpaceDetailsScreen({
    super.key,
    required this.space,
    required this.onChangeScreen,
  });

  @override
  State<WorkingSpaceDetailsScreen> createState() =>
      _WorkingSpaceDetailsScreenState();
}

class _WorkingSpaceDetailsScreenState extends State<WorkingSpaceDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // TODO: Učitaj podatke za ovaj workspace preko ID-a
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // HEADER (možeš staviti naziv prostora kasnije)
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  widget.onChangeScreen(
                    WorkingSpacesScreen(onChangeScreen: widget.onChangeScreen),
                  );
                },
              ),
              const SizedBox(width: 8),
              // alignment: Alignment.centerLeft,
              Text(
                "${widget.space.name}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        // TAB BAR
        TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          tabs: const [
            Tab(text: "Detalji"),
            Tab(text: "Space uniti"),
            Tab(text: "Slike"),
          ],
        ),

        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildDetailsTab(),
              _buildSpaceUnitsTab(),
              _buildImagesTab(),
            ],
          ),
        ),
      ],
    );
  }

  // -------------------------------
  // TAB 1: DETALJI
  // -------------------------------
  Widget _buildDetailsTab() {
    // return Padding(
    //   padding: const EdgeInsets.all(16),
    //   child: ListView(
    //     children: [
    //       const Text(
    //         "Informacije o prostoru",
    //         style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    //       ),

    //       const SizedBox(height: 20),

    //       // TODO: Ovdje stavi formu sa TextFieldovima
    //       Text("Ovdje će biti naziv, opis, grad..."),

    //       const SizedBox(height: 20),
    //       ElevatedButton(
    //         onPressed: () {
    //           // TODO: Update workspace
    //         },
    //         child: const Text("Spasi izmjene"),
    //       ),
    //     ],
    //   ),
    // );
    return WorkingSpaceFormScreen(
      workspace: widget.space,
      onChangeScreen: widget.onChangeScreen,
    );
  }

  // -------------------------------
  // TAB 2: SPACE UNITI
  // -------------------------------
  Widget _buildSpaceUnitsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search + Add button
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "Pretraga space unit-a",
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    // TODO: filtriraj listu
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  // TODO: Dodavanje novog space unita
                },
                child: const Text("Dodaj space unit"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // LISTA / TABELA
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: ListView.builder(
                itemCount: 10, // TODO: zamijeni stvarnim podacima
                itemBuilder: (_, index) {
                  return ListTile(
                    title: Text("Space unit #$index"),
                    subtitle: const Text("Detalji ovdje..."),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Ovdje otvaramo novi ekran, ali opet unutar mastera
                      widget.onChangeScreen(
                        Text("Ovdje ide ekran sa detaljima space unita"),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------
  // TAB 3: SLIKE
  // -------------------------------
  Widget _buildImagesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
        ),
        itemCount: 6, // TODO: zamijeni stvarnim slikama
        itemBuilder: (_, index) {
          return Container(
            color: Colors.grey.shade300,
            child: const Icon(Icons.image, size: 40),
          );
        },
      ),
    );
  }
}

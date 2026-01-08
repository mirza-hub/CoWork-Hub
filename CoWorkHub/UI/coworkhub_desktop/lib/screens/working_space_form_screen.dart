import 'package:coworkhub_desktop/models/city.dart';
import 'package:coworkhub_desktop/providers/city_provider.dart';
import 'package:coworkhub_desktop/screens/working_space_screen.dart';
import 'package:flutter/material.dart';
import 'package:coworkhub_desktop/models/working_space.dart';
import 'package:coworkhub_desktop/providers/working_space_provider.dart';
import 'package:another_flushbar/flushbar.dart';

class WorkingSpaceFormScreen extends StatefulWidget {
  final WorkingSpace? workspace;
  final Function(Widget) onChangeScreen;

  const WorkingSpaceFormScreen({
    super.key,
    required this.workspace,
    required this.onChangeScreen,
  });

  @override
  State<WorkingSpaceFormScreen> createState() => _WorkingSpaceFormScreenState();
}

class _WorkingSpaceFormScreenState extends State<WorkingSpaceFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Polja forme
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  int? _cityId;
  List<City> _cities = [];
  bool _loadingCities = true;

  final WorkingSpaceProvider provider = WorkingSpaceProvider();
  final CityProvider _cityProvider = CityProvider();

  bool get isEdit => widget.workspace != null;

  @override
  void initState() {
    super.initState();

    // Ako je edit moda, popuniti vrijednosti
    _nameController = TextEditingController(text: widget.workspace?.name ?? "");
    _addressController = TextEditingController(
      text: widget.workspace?.address ?? "",
    );
    _descriptionController = TextEditingController(
      text: widget.workspace?.description ?? "",
    );

    _cityId = widget.workspace?.cityId;
    _loadCities();
  }

  Future<void> _loadCities() async {
    final filter = {'RetrieveAll': true};
    var result = await _cityProvider.get(filter: filter);
    setState(() {
      _cities = result.resultList;
      _loadingCities = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    var request = {
      "name": _nameController.text,
      "address": _addressController.text,
      "description": _descriptionController.text,
      "cityId": _cityId,
    };

    if (isEdit) {
      // UPDATE
      await provider.update(widget.workspace!.workingSpacesId, request);
      _showSuccessFlushbar("Prostor je uspješno ažuriran.");
    } else {
      // CREATE
      await provider.insert(request);
      _showSuccessFlushbar("Prostor je uspješno kreiran.");
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lijeva kolona (strelica)
        if (!isEdit)
          Padding(
            padding: const EdgeInsets.only(top: 16, left: 16),
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              iconSize: 28,
              onPressed: () {
                widget.onChangeScreen(
                  WorkingSpacesScreen(onChangeScreen: widget.onChangeScreen),
                );
              },
            ),
          )
        else
          const SizedBox(width: 60), // prazan prostor da layout ostane isti
        // Desna kolona (forma centrirana)
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      // Naslov
                      Center(
                        child: Text(
                          isEdit ? "Uredi prostor" : "Kreiraj novi prostor",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Naziv",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Naziv je obavezan" : null,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(
                          labelText: "Adresa",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? "Adresa je obavezna"
                            : null,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: "Opis",
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) =>
                            v == null || v.isEmpty ? "Opis je obavezan" : null,
                      ),

                      const SizedBox(height: 16),

                      _loadingCities
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: "Grad",
                                border: OutlineInputBorder(),
                              ),
                              initialValue: _cityId,
                              items: _cities
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c.cityId,
                                      child: Text(c.cityName),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) => setState(() => _cityId = v),
                              validator: (v) =>
                                  v == null ? "Molimo izaberite grad" : null,
                            ),

                      const SizedBox(height: 30),

                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              isEdit ? "Sačuvaj" : "Spasi",
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showSuccessFlushbar(String message) {
    late final Flushbar flush;

    flush = Flushbar(
      message: message,
      duration: const Duration(
        seconds: 3,
      ), // ili null ako želiš da čekamo user klik
      backgroundColor: Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
      mainButton: TextButton(
        onPressed: () {
          flush.dismiss(); // korisnik može ručno zatvoriti flushbar
        },
        child: const Text("OK", style: TextStyle(color: Colors.white)),
      ),
      onStatusChanged: (status) {
        if (status == FlushbarStatus.DISMISSED && !isEdit) {
          // Očisti formu samo ako je CREATE, ne UPDATE
          _nameController.clear();
          _addressController.clear();
          _descriptionController.clear();
          _cityId = null;

          setState(() {}); // refresh forme
        }
      },
    );

    flush.show(context);
  }
}

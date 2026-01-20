import 'dart:convert';

import 'package:coworkhub_desktop/models/city.dart';
import 'package:coworkhub_desktop/providers/city_provider.dart';
import 'package:coworkhub_desktop/screens/map_picker_screen.dart';
import 'package:coworkhub_desktop/screens/working_space_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:coworkhub_desktop/models/working_space.dart';
import 'package:coworkhub_desktop/providers/working_space_provider.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

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

  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  int? _cityId;
  List<City> _cities = [];
  bool _loadingCities = true;
  double? _latitude;
  double? _longitude;

  final WorkingSpaceProvider provider = WorkingSpaceProvider();
  final CityProvider _cityProvider = CityProvider();

  bool get isEdit => widget.workspace != null;

  @override
  void initState() {
    super.initState();

    _latitude = widget.workspace?.latitude;
    _longitude = widget.workspace?.longitude;

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
    if (_latitude == null || _longitude == null) {
      showTopFlushBar(
        context: context,
        message: "Molimo odaberite lokaciju na karti",
        backgroundColor: Colors.red,
      );
      return;
    }

    var request = {
      "name": _nameController.text,
      "address": _addressController.text,
      "description": _descriptionController.text,
      "cityId": _cityId,
      "latitude": _latitude,
      "longitude": _longitude,
    };
    try {
      if (isEdit) {
        await provider.update(widget.workspace!.workingSpacesId, request);
        showTopFlushBar(
          context: context,
          message: "Prostor je uspješno ažuriran",
          backgroundColor: Colors.green,
        );
      } else {
        await provider.insert(request);
        showTopFlushBar(
          context: context,
          message: "Prostor je uspješno kreiran",
          backgroundColor: Colors.green,
        );
        _resetForm();
      }
    } catch (e) {
      if (e is http.Response) {
        try {
          final errorData = jsonDecode(e.body);
          if (errorData['errors'] != null &&
              errorData['errors']['userError'] != null) {
            String message = (errorData['errors']['userError'] as List).join(
              "\n",
            );
            showTopFlushBar(
              context: context,
              message: message,
              backgroundColor: Colors.red,
            );
          } else {
            showTopFlushBar(
              context: context,
              message: "Greška: ${e.statusCode}",
              backgroundColor: Colors.red,
            );
          }
        } catch (_) {
          showTopFlushBar(
            context: context,
            message: "Greška: ${e.statusCode} - ${e.body}",
            backgroundColor: Colors.red,
          );
        }
      } else {
        showTopFlushBar(
          context: context,
          message: "Došlo je do greške: $e",
          backgroundColor: Colors.red,
        );
      }
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();

    _nameController.clear();
    _addressController.clear();
    _descriptionController.clear();

    _cityId = null;
    _latitude = null;
    _longitude = null;

    setState(() {});
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
          const SizedBox(width: 60),
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
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(40),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9\s\-]'),
                          ),
                        ],
                        validator: (v) =>
                            v == null || v.isEmpty ? "Naziv je obavezan" : null,
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: "Adresa",
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            tooltip: "Odaberi lokaciju na karti",
                            icon: Icon(
                              (_latitude != null && _longitude != null)
                                  ? Icons.map
                                  : Icons.map_outlined,
                              color: (_latitude != null && _longitude != null)
                                  ? Colors.green
                                  : Colors.grey,
                            ),
                            onPressed: () async {
                              final result = await Navigator.of(context)
                                  .push<Map<String, dynamic>>(
                                    MaterialPageRoute(
                                      builder: (_) => MapPickerScreen(
                                        initialLat: _latitude,
                                        initialLon: _longitude,
                                      ),
                                    ),
                                  );

                              if (result != null) {
                                setState(() {
                                  _latitude = result['lat'];
                                  _longitude = result['lon'];
                                  _addressController.text =
                                      result['address'] ??
                                      _addressController.text;
                                });
                              }
                            },
                          ),
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(30)],
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
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(200),
                        ],
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
}

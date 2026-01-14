import 'dart:convert';

import 'package:coworkhub_desktop/models/city.dart';
import 'package:coworkhub_desktop/models/country.dart';
import 'package:coworkhub_desktop/providers/city_provider.dart';
import 'package:coworkhub_desktop/providers/country_provider.dart';
import 'package:coworkhub_desktop/screens/city_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class CityFormScreen extends StatefulWidget {
  final City? city;
  final void Function(Widget) onChangeScreen;

  const CityFormScreen({
    super.key,
    required this.city,
    required this.onChangeScreen,
  });

  @override
  State<CityFormScreen> createState() => _CityFormScreenState();
}

class _CityFormScreenState extends State<CityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CityProvider _cityProvider = CityProvider();
  final CountryProvider _countryProvider = CountryProvider();

  late TextEditingController _nameController;
  late TextEditingController _postalController;

  List<Country> countries = [];
  int? selectedCountryId;
  bool loadingCountries = true;

  bool get isEdit => widget.city != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.city?.cityName ?? "");
    _postalController = TextEditingController(
      text: widget.city?.postalCode ?? "",
    );
    selectedCountryId = widget.city?.countryId;

    _loadCountries();
  }

  Future<void> _loadCountries() async {
    final result = await _countryProvider.get(
      filter: {"RetrieveAll": true, "IsDeleted": false},
    );
    setState(() {
      countries = result.resultList;
      loadingCountries = false;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final request = {
      "cityName": _nameController.text,
      "countryId": selectedCountryId,
      "postalCode": _postalController.text,
    };
    try {
      if (isEdit) {
        await _cityProvider.update(widget.city!.cityId, request);
        showTopFlushBar(
          context: context,
          message: "Grad je uspješno ažuriran",
          backgroundColor: Colors.green,
        );
      } else {
        await _cityProvider.insert(request);
        showTopFlushBar(
          context: context,
          message: "Grad je uspješno dodan",
          backgroundColor: Colors.green,
        );

        setState(() {
          _nameController.clear();
          _postalController.clear();
          selectedCountryId = null;
        });
      }
    } catch (e) {
      if (e is http.Response) {
        try {
          final errorData = jsonDecode(e.body);
          if (errorData['errors'] != null &&
              errorData['errors']['userError'] != null) {
            String message = errorData['errors']['userError'].join("\n");
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

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// BACK ARROW
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 28,
            onPressed: () {
              widget.onChangeScreen(
                CityScreen(onChangeScreen: widget.onChangeScreen),
              );
            },
          ),
        ),

        /// FORM
        Expanded(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      Center(
                        child: Text(
                          isEdit ? "Uredi grad" : "Dodaj novi grad",
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
                          labelText: "Naziv grada",
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9\s\-]'),
                          ),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Naziv je obavezan";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _postalController,
                        decoration: const InputDecoration(
                          labelText: "Poštanski broj",
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(10),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return "Poštanski broj je obavezan";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      loadingCountries
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<int>(
                              value: selectedCountryId,
                              decoration: const InputDecoration(
                                labelText: "Država",
                                border: OutlineInputBorder(),
                              ),
                              items: countries
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c.countryId,
                                      child: Text(c.countryName),
                                    ),
                                  )
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => selectedCountryId = v),
                              validator: (v) =>
                                  v == null ? "Izaberite državu" : null,
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

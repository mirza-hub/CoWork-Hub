import 'dart:convert';

import 'package:coworkhub_desktop/models/country.dart';
import 'package:coworkhub_desktop/providers/country_provider.dart';
import 'package:coworkhub_desktop/screens/country_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class CountryFormScreen extends StatefulWidget {
  final Country? country;
  final void Function(Widget) onChangeScreen;

  const CountryFormScreen({
    super.key,
    this.country,
    required this.onChangeScreen,
  });

  @override
  State<CountryFormScreen> createState() => _CountryFormScreenState();
}

class _CountryFormScreenState extends State<CountryFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final CountryProvider _countryProvider = CountryProvider();

  late TextEditingController _nameController;

  bool get isEdit => widget.country != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.country?.countryName ?? "",
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final request = {"countryName": _nameController.text};

    try {
      if (isEdit) {
        await _countryProvider.update(widget.country!.countryId, request);
        showTopFlushBar(
          context: context,
          message: "Država uspješno ažurirana",
          backgroundColor: Colors.green,
        );
      } else {
        await _countryProvider.insert(request);
        showTopFlushBar(
          context: context,
          message: "Država uspješno dodana",
          backgroundColor: Colors.green,
        );
        setState(() {
          _nameController.clear();
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
                CountryScreen(onChangeScreen: widget.onChangeScreen),
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
                          isEdit ? "Uredi državu" : "Dodaj novu državu",
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
                          labelText: "Naziv države",
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9\s\-]'),
                          ),
                        ],
                        validator: (v) =>
                            v == null || v.isEmpty ? "Naziv je obavezan" : null,
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

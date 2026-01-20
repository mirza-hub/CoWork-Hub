import 'dart:convert';

import 'package:coworkhub_desktop/models/resource.dart';
import 'package:coworkhub_desktop/providers/resource_provider.dart';
import 'package:coworkhub_desktop/screens/resource_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class ResourceFormScreen extends StatefulWidget {
  final Resource? resource;
  final void Function(Widget) onChangeScreen;

  const ResourceFormScreen({
    super.key,
    this.resource,
    required this.onChangeScreen,
  });

  @override
  State<ResourceFormScreen> createState() => _ResourceFormScreenState();
}

class _ResourceFormScreenState extends State<ResourceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ResourceProvider _resourceProvider = ResourceProvider();

  late TextEditingController _nameController;

  bool get isEdit => widget.resource != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.resource?.resourceName ?? "",
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final request = {"resourceName": _nameController.text};

    try {
      if (isEdit) {
        await _resourceProvider.update(widget.resource!.resourcesId, request);
        showTopFlushBar(
          context: context,
          message: "Resurs uspješno ažuriran",
          backgroundColor: Colors.green,
        );
      } else {
        await _resourceProvider.insert(request);
        showTopFlushBar(
          context: context,
          message: "Resurs uspješno dodan",
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

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Strelica nazad
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 28,
            onPressed: () {
              widget.onChangeScreen(
                ResourceScreen(onChangeScreen: widget.onChangeScreen),
              );
            },
          ),
        ),

        // Forma
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
                          isEdit ? "Uredi resurs" : "Dodaj novi resurs",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Ime resursa
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Naziv resursa",
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(20),
                          FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9_-\s]'),
                          ),
                        ],
                        validator: (v) =>
                            v == null || v.isEmpty ? "Naziv je obavezan" : null,
                      ),

                      const SizedBox(height: 30),

                      // Dugme sačuvaj/spasi
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

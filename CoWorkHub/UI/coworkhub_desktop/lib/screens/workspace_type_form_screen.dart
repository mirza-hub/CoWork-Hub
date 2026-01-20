import 'dart:convert';

import 'package:coworkhub_desktop/models/workspace_type.dart';
import 'package:coworkhub_desktop/providers/workspace_type_provider.dart';
import 'package:coworkhub_desktop/screens/workspace_type_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class WorkspaceTypeFormScreen extends StatefulWidget {
  final WorkspaceType? workspaceType;
  final void Function(Widget) onChangeScreen;

  const WorkspaceTypeFormScreen({
    super.key,
    this.workspaceType,
    required this.onChangeScreen,
  });

  @override
  State<WorkspaceTypeFormScreen> createState() =>
      _WorkspaceTypeFormScreenState();
}

class _WorkspaceTypeFormScreenState extends State<WorkspaceTypeFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final WorkspaceTypeProvider _provider = WorkspaceTypeProvider();

  late TextEditingController _nameController;

  bool get isEdit => widget.workspaceType != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.workspaceType?.typeName ?? "",
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final request = {"typeName": _nameController.text};

    try {
      if (isEdit) {
        await _provider.update(widget.workspaceType!.workspaceTypeId, request);
        showTopFlushBar(
          context: context,
          message: "Tip prostora uspješno ažuriran",
          backgroundColor: Colors.green,
        );
      } else {
        await _provider.insert(request);
        showTopFlushBar(
          context: context,
          message: "Tip prostora uspješno dodat",
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
                WorkspaceTypeScreen(onChangeScreen: widget.onChangeScreen),
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
                          isEdit
                              ? "Uredi tip prostora"
                              : "Dodaj novi tip prostora",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Naziv tipa prostora
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: "Naziv tipa prostora",
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(20)],
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

import 'dart:convert';

import 'package:coworkhub_desktop/models/role.dart';
import 'package:coworkhub_desktop/providers/role_provider.dart';
import 'package:coworkhub_desktop/screens/role_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class RoleFormScreen extends StatefulWidget {
  final Role? role;
  final void Function(Widget) onChangeScreen;

  const RoleFormScreen({super.key, this.role, required this.onChangeScreen});

  @override
  State<RoleFormScreen> createState() => _RoleFormScreenState();
}

class _RoleFormScreenState extends State<RoleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final RoleProvider _roleProvider = RoleProvider();

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  String _initialName = "";
  String? _initialDescription;

  bool get isEdit => widget.role != null;
  bool get isDeleted => widget.role?.isDeleted == true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.role?.roleName ?? "");
    _descriptionController = TextEditingController(
      text: widget.role?.description ?? "",
    );
    _initialName = widget.role?.roleName ?? "";
    _initialDescription = widget.role?.description;
  }

  Future<void> _save() async {
    if (isDeleted) return;
    if (!_formKey.currentState!.validate()) return;

    final request = {
      "roleName": _nameController.text.trim(),
      "description": _descriptionController.text.trim(),
    };

    try {
      if (isEdit) {
        if (_nameController.text.trim() == _initialName &&
            _descriptionController.text.trim() == (_initialDescription ?? "")) {
          showTopFlushBar(
            context: context,
            message: "Niste ništa promijenili",
            backgroundColor: Colors.orange,
          );
          return;
        }
        await _roleProvider.update(widget.role!.rolesId, request);
        setState(() {
          _initialName = _nameController.text;
          _initialDescription = _descriptionController.text;
        });
        showTopFlushBar(
          context: context,
          message: "Uloga uspješno ažurirana",
          backgroundColor: Colors.green,
        );
      } else {
        await _roleProvider.insert(request);
        showTopFlushBar(
          context: context,
          message: "Uloga uspješno dodana",
          backgroundColor: Colors.green,
        );
        _nameController.clear();
        _descriptionController.clear();
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

  Future<void> _restore() async {
    try {
      await _roleProvider.restore(widget.role!.rolesId);
      showTopFlushBar(
        context: context,
        message: "Uloga uspješno vraćena",
        backgroundColor: Colors.green,
      );
      widget.onChangeScreen(RoleScreen(onChangeScreen: widget.onChangeScreen));
    } catch (e) {
      showTopFlushBar(
        context: context,
        message: "Greška pri vraćanju uloge",
        backgroundColor: Colors.red,
      );
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
                RoleScreen(onChangeScreen: widget.onChangeScreen),
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
                          isEdit ? "Uredi ulogu" : "Dodaj novu ulogu",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),
                      TextFormField(
                        controller: _nameController,
                        enabled: !isDeleted,
                        decoration: const InputDecoration(
                          labelText: "Naziv uloge",
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [LengthLimitingTextInputFormatter(30)],
                        validator: (value) {
                          if (value == null) return "Naziv je obavezan";

                          final v = value.trim();

                          if (v.isEmpty) {
                            return "Naziv je obavezan";
                          }

                          if (v.length < 2) {
                            return "Naziv mora imati barem 2 slova";
                          }

                          if (v.length > 30) {
                            return "Naziv ne može biti duži od 30 znakova";
                          }

                          final regex = RegExp(
                            r"^[a-zA-ZčćžšđČĆŽŠĐ]+([\s\-'][a-zA-ZčćžšđČĆŽŠĐ]+)*$",
                          );

                          if (!RegExp(
                            r'^[A-Za-zČĆŽŠĐčćžšđ]+(?:[ -][A-Za-zČĆŽŠĐčćžšđ]+)*$',
                          ).hasMatch(value)) {
                            return "Naziv ne može počinjati ili završavati razmakom ili -";
                          }

                          if (!regex.hasMatch(v)) {
                            return "Naziv može sadržavati samo slova, razmake i crticu";
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _descriptionController,
                        enabled: !isDeleted,
                        decoration: const InputDecoration(
                          labelText: "Opis (opciono)",
                          border: OutlineInputBorder(),
                        ),
                        maxLength: 200,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: isDeleted ? _restore : _save,
                            style: isDeleted
                                ? ElevatedButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  )
                                : ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                            child: Text(
                              isDeleted
                                  ? "Vrati ulogu"
                                  : (isEdit ? "Sačuvaj" : "Spasi"),
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

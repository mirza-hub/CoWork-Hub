import 'dart:convert';

import 'package:coworkhub_desktop/models/payment_method.dart';
import 'package:coworkhub_desktop/providers/payment_method_provider.dart';
import 'package:coworkhub_desktop/screens/payment_method_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class PaymentMethodFormScreen extends StatefulWidget {
  final PaymentMethod? paymentMethod;
  final void Function(Widget) onChangeScreen;

  const PaymentMethodFormScreen({
    super.key,
    this.paymentMethod,
    required this.onChangeScreen,
  });

  @override
  State<PaymentMethodFormScreen> createState() =>
      _PaymentMethodFormScreenState();
}

class _PaymentMethodFormScreenState extends State<PaymentMethodFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final PaymentMethodProvider _provider = PaymentMethodProvider();

  late TextEditingController _nameController;
  String _initialName = "";

  bool get isEdit => widget.paymentMethod != null;
  bool get isDeleted => widget.paymentMethod?.isDeleted == true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.paymentMethod?.paymentMethodName ?? "",
    );
    _initialName = widget.paymentMethod?.paymentMethodName ?? "";
  }

  Future<void> _save() async {
    if (isDeleted) return;
    if (!_formKey.currentState!.validate()) return;

    final request = {"paymentMethodName": _nameController.text};

    try {
      if (isEdit) {
        if (_nameController.text.trim() == _initialName.trim()) {
          showTopFlushBar(
            context: context,
            message: "Niste ništa promijenili",
            backgroundColor: Colors.orange,
          );
          return;
        }
        await _provider.update(widget.paymentMethod!.paymentMethodId, request);
        _initialName = _nameController.text;
        showTopFlushBar(
          context: context,
          message: "Metoda plaćanja uspješno ažurirana",
          backgroundColor: Colors.green,
        );
      } else {
        await _provider.insert(request);
        showTopFlushBar(
          context: context,
          message: "Metoda plaćanja uspješno dodana",
          backgroundColor: Colors.green,
        );
        _nameController.clear();
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
      await _provider.restore(widget.paymentMethod!.paymentMethodId);
      showTopFlushBar(
        context: context,
        message: "Metoda plaćanja uspješno vraćena",
        backgroundColor: Colors.green,
      );
      widget.onChangeScreen(
        PaymentMethodScreen(onChangeScreen: widget.onChangeScreen),
      );
    } catch (e) {
      showTopFlushBar(
        context: context,
        message: "Greška pri vraćanju",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, left: 16),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            iconSize: 28,
            onPressed: () {
              widget.onChangeScreen(
                PaymentMethodScreen(onChangeScreen: widget.onChangeScreen),
              );
            },
          ),
        ),
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
                              ? "Uredi metodu plaćanja"
                              : "Dodaj novu metodu plaćanja",
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
                          labelText: "Naziv metode",
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
                      const SizedBox(height: 30),
                      Center(
                        child: SizedBox(
                          width: 150,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: isDeleted ? _restore : _save,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDeleted
                                  ? Colors.orange
                                  : Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              isDeleted
                                  ? "Vrati"
                                  : (isEdit ? "Sačuvaj" : "Spasi"),
                              style: TextStyle(color: Colors.white),
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

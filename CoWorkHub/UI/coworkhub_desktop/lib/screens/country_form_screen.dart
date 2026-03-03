import 'package:coworkhub_desktop/exceptions/user_exception.dart';
import 'package:coworkhub_desktop/models/country.dart';
import 'package:coworkhub_desktop/providers/country_provider.dart';
import 'package:coworkhub_desktop/screens/country_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  String _initialName = "";

  bool get isEdit => widget.country != null;
  bool get isDeleted => widget.country?.isDeleted == true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.country?.countryName ?? "",
    );
    _initialName = widget.country?.countryName ?? "";
  }

  Future<void> _save() async {
    if (isDeleted) return;
    if (!_formKey.currentState!.validate()) return;

    final request = {"countryName": _nameController.text};

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
        await _countryProvider.update(widget.country!.countryId, request);
        setState(() {
          _initialName = _nameController.text;
        });
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
      if (e is UserException) {
        showTopFlushBar(
          context: context,
          message: e.message,
          backgroundColor: Colors.red,
        );
      } else {
        showTopFlushBar(
          context: context,
          message: "Neočekivana greška",
          backgroundColor: Colors.red,
        );
      }
    }
  }

  Future<void> _restore() async {
    try {
      await _countryProvider.restore(widget.country!.countryId);
      showTopFlushBar(
        context: context,
        message: "Država uspješno vraćena",
        backgroundColor: Colors.green,
      );
      widget.onChangeScreen(
        CountryScreen(onChangeScreen: widget.onChangeScreen),
      );
    } catch (e) {
      showTopFlushBar(
        context: context,
        message: "Greška pri vraćanju države",
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
                CountryScreen(onChangeScreen: widget.onChangeScreen),
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
                        enabled: !isDeleted,
                        decoration: const InputDecoration(
                          labelText: "Naziv države",
                          border: OutlineInputBorder(),
                        ),
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(30),
                          FilteringTextInputFormatter.allow(
                            RegExp(r"[a-zA-ZčćžšđČĆŽŠĐ\s\-']"),
                          ),
                        ],
                        validator: (value) {
                          if (value == null) return "Naziv je obavezan";

                          final v = value.trim();

                          if (v.isEmpty) {
                            return "Naziv je obavezan";
                          }

                          if (v.length < 2) {
                            return "Naziv mora imati barem 2 slova";
                          }

                          if (v.length > 56) {
                            return "Naziv ne može biti duži od 56 znakova";
                          }

                          final regex = RegExp(
                            r"^[a-zA-ZčćžšđČĆŽŠĐ]+([\s\-'][a-zA-ZčćžšđČĆŽŠĐ]+)*$",
                          );
                          if (!regex.hasMatch(v)) {
                            return "Naziv može sadržavati samo slova, razmake i crticu";
                          }
                          if (!RegExp(
                            r'^[A-Za-zČĆŽŠĐčćžšđ]+(?:[ -][A-Za-zČĆŽŠĐčćžšđ]+)*$',
                          ).hasMatch(value)) {
                            return "Naziv ne može počinjati ili završavati razmakom ili -";
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
                                  ? "Vrati državu"
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

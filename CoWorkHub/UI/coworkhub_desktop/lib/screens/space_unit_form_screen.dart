import 'dart:convert';
import 'dart:typed_data';
import 'package:coworkhub_desktop/models/resource.dart';
import 'package:coworkhub_desktop/models/review.dart';
import 'package:coworkhub_desktop/models/space_unit.dart';
import 'package:coworkhub_desktop/models/space_unit_image.dart';
import 'package:coworkhub_desktop/models/working_space.dart';
import 'package:coworkhub_desktop/models/workspace_type.dart';
import 'package:coworkhub_desktop/providers/base_provider.dart';
import 'package:coworkhub_desktop/providers/resource_provider.dart';
import 'package:coworkhub_desktop/providers/review_provider.dart';
import 'package:coworkhub_desktop/providers/space_unit_image_provider.dart';
import 'package:coworkhub_desktop/providers/space_unit_provider.dart';
import 'package:coworkhub_desktop/providers/space_unit_resources_provider.dart';
import 'package:coworkhub_desktop/providers/workspace_type_provider.dart';
import 'package:coworkhub_desktop/screens/working_space_details_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class SpaceUnitFormScreen extends StatefulWidget {
  final SpaceUnit? spaceUnit;
  final WorkingSpace space;
  final Function(Widget) onChangeScreen;

  const SpaceUnitFormScreen({
    super.key,
    required this.spaceUnit,
    required this.space,
    required this.onChangeScreen,
  });

  @override
  State<SpaceUnitFormScreen> createState() => _SpaceUnitFormScreenState();
}

class _SpaceUnitFormScreenState extends State<SpaceUnitFormScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;

  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _capacityController;
  late TextEditingController _priceController;

  List<Resource> _resources = [];
  List<int> _selectedResourceIds = [];
  List<WorkspaceType> _workspaceTypes = [];
  WorkspaceType? _selectedWorkspaceType;
  List<Uint8List> _selectedImagesBytes = [];
  List<SpaceUnitImage> _images = [];
  List<String> _allowedActions = [];

  final SpaceUnitProvider _spaceUnitProvider = SpaceUnitProvider();
  final ResourceProvider _resourceProvider = ResourceProvider();
  final WorkspaceTypeProvider _workspaceTypeProvider = WorkspaceTypeProvider();
  final SpaceUnitResourcesProvider _spaceUnitResourcesProvider =
      SpaceUnitResourcesProvider();
  late SpaceUnitImageProvider _imageProvider;
  late SpaceUnit? _currentSpaceUnit;

  Map<String, String> actionDisplayNames = {
    'activate': 'Aktiviraj',
    'delete': 'Obriši',
    'hide': 'Sakrij',
    'setmaintenance': 'Održavanje',
    'edit': 'Uredi',
    'restore': 'Vrati',
  };

  bool _loadingResources = true;
  bool _loadingWorkspaceTypes = true;
  bool _loadingImages = true;
  bool get isEdit => _currentSpaceUnit != null;
  bool _canEdit = false;

  Map<String, Color> stateColors = {
    'draft': Colors.orange,
    'active': Colors.green,
    'maintenance': Colors.blue,
    'hidden': Colors.grey,
    'deleted': Colors.red,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    _currentSpaceUnit = widget.spaceUnit;

    _nameController = TextEditingController(
      text: _currentSpaceUnit?.name ?? "",
    );
    _descriptionController = TextEditingController(
      text: _currentSpaceUnit?.description ?? "",
    );
    _capacityController = TextEditingController(
      text: _currentSpaceUnit?.capacity.toString() ?? "",
    );
    _priceController = TextEditingController(
      text: _currentSpaceUnit?.pricePerDay.toString() ?? "",
    );

    _selectedResourceIds =
        _currentSpaceUnit?.spaceUnitResources
            .map((r) => r.resourcesId)
            .toList() ??
        [];

    _imageProvider = SpaceUnitImageProvider();

    _loadResources();
    _loadWorkspaceTypes();

    if (_currentSpaceUnit == null) {
      _canEdit = true;
      _loadingImages = false;
    } else {
      _canEdit = _currentSpaceUnit!.stateMachine.toLowerCase() == "draft";
      _loadImages();
      _loadAllowedActions();
      _loadSelectedResources();
    }
  }

  Future<void> _loadSelectedResources() async {
    if (!isEdit) return; // samo za edit

    try {
      final result = await _spaceUnitResourcesProvider.get(
        filter: {
          'SpaceUnitId': widget.spaceUnit!.spaceUnitId,
          'RetrieveAll': true,
        },
      );

      // result.resultList je lista SpaceUnitResources
      final resourceIds = result.resultList
          .map<int>((e) => e.resourcesId)
          .whereType<int>()
          .toList();

      setState(() {
        _selectedResourceIds = resourceIds;
      });
    } catch (e) {
      String message = "Greška prilikom učitavanja selektovani hresursa.";

      if (e is http.Response) {
        try {
          final errorJson = jsonDecode(e.body);
          if (errorJson["errors"] != null &&
              errorJson["errors"]["userError"] != null) {
            message = errorJson["errors"]["userError"][0];
          }
        } catch (_) {}
      }

      Flushbar(
        message: message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  Future<void> _loadImages() async {
    setState(() => _loadingImages = true);
    final filter = {
      'SpaceUnitId': _currentSpaceUnit!.spaceUnitId,
      'RetrieveAll': true,
      'IsDeleted': false,
    };
    try {
      final images = await _imageProvider.get(filter: filter);
      setState(() => _images = images.resultList);
    } catch (e) {
      String message = "Greška prilikom učitavanja slika.";

      if (e is http.Response) {
        try {
          final errorJson = jsonDecode(e.body);
          if (errorJson["errors"] != null &&
              errorJson["errors"]["userError"] != null) {
            message = errorJson["errors"]["userError"][0];
          }
        } catch (_) {}
      }

      Flushbar(
        message: message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    } finally {
      setState(() => _loadingImages = false);
    }
  }

  Future<void> _loadAllowedActions() async {
    try {
      final actions = await _spaceUnitProvider.allowedActions(
        _currentSpaceUnit!.spaceUnitId,
      );
      setState(() {
        _allowedActions = actions;
      });
    } catch (e) {
      String message = "Greška prilikom učitavanja dozvoljenih akcija.";

      if (e is http.Response) {
        try {
          final errorJson = jsonDecode(e.body);
          if (errorJson["errors"] != null &&
              errorJson["errors"]["userError"] != null) {
            message = errorJson["errors"]["userError"][0];
          }
        } catch (_) {}
      }

      Flushbar(
        message: message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  Future<void> _loadWorkspaceTypes() async {
    try {
      var result = await _workspaceTypeProvider.get(
        filter: {"RetrieveAll": true},
      );
      setState(() {
        _workspaceTypes = result.resultList;
        if (_currentSpaceUnit != null) {
          _selectedWorkspaceType = _workspaceTypes.firstWhere(
            (t) => t.workspaceTypeId == _currentSpaceUnit!.workspaceTypeId,
            orElse: () => _workspaceTypes.first,
          );
        }
        _loadingWorkspaceTypes = false;
      });
    } catch (e) {
      setState(() => _loadingWorkspaceTypes = false);
      String message = "Greška prilikom učitavanja tipova prostora.";

      if (e is http.Response) {
        try {
          final errorJson = jsonDecode(e.body);
          if (errorJson["errors"] != null &&
              errorJson["errors"]["userError"] != null) {
            message = errorJson["errors"]["userError"][0];
          }
        } catch (_) {}
      }

      Flushbar(
        message: message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  Future<void> _loadResources() async {
    try {
      var result = await _resourceProvider.get(filter: {"RetrieveAll": true});
      setState(() {
        _resources = result.resultList;
        _loadingResources = false;
      });
    } catch (e) {
      setState(() => _loadingResources = false);
      String message = "Greška prilikom učitavanja resursa.";

      if (e is http.Response) {
        try {
          final errorJson = jsonDecode(e.body);
          if (errorJson["errors"] != null &&
              errorJson["errors"]["userError"] != null) {
            message = errorJson["errors"]["userError"][0];
          }
        } catch (_) {}
      }

      Flushbar(
        message: message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  Future<void> _pickImages() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result == null) return;

    List<Uint8List> newImages = result.files
        .where((f) => f.bytes != null)
        .map((f) => f.bytes!)
        .toList();

    if (!isEdit) {
      // INSERT — samo u memoriji
      setState(() {
        _selectedImagesBytes.addAll(newImages);
      });
      return;
    }

    // EDIT — odmah šalji na backend
    try {
      await _imageProvider.uploadBase64Images(
        spaceUnitId: _currentSpaceUnit!.spaceUnitId!,
        base64Images: newImages.map((e) => base64Encode(e)).toList(),
      );

      await _loadImages();
      showTopFlushBar(
        context: context,
        message: "Slike uspješno dodane",
        backgroundColor: Colors.green,
      );
    } catch (e) {
      String message = "Greška prilikom odabira slika.";

      if (e is http.Response) {
        try {
          final errorJson = jsonDecode(e.body);
          if (errorJson["errors"] != null &&
              errorJson["errors"]["userError"] != null) {
            message = errorJson["errors"]["userError"][0];
          }
        } catch (_) {}
      }

      Flushbar(
        message: message,
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(10),
        borderRadius: BorderRadius.circular(8),
        flushbarPosition: FlushbarPosition.TOP,
      ).show(context);
    }
  }

  void _openImageViewer(int initialIndex) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            ImageViewer(images: _images, initialIndex: initialIndex),
      ),
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    List<String> base64Images = _selectedImagesBytes
        .map((e) => base64Encode(e))
        .toList();

    var request = {
      "workingSpaceId": widget.space.workingSpacesId,
      "name": _nameController.text,
      "description": _descriptionController.text,
      'workspaceTypeId': _selectedWorkspaceType?.workspaceTypeId,
      "capacity": int.tryParse(_capacityController.text),
      "pricePerDay": double.tryParse(_priceController.text),
      "resourcesList": _selectedResourceIds
          .map(
            (id) => {"resourcesId": id, "resourceName": "", "isDeleted": false},
          )
          .toList(),
      "base64Images": base64Images,
    };

    if (isEdit) {
      var request2 = {
        "name": _nameController.text,
        "description": _descriptionController.text,
        "capacity": int.tryParse(_capacityController.text),
        "pricePerDay": double.tryParse(_priceController.text),
        'workspaceTypeId': _selectedWorkspaceType?.workspaceTypeId,
        "resourcesList": _selectedResourceIds
            .map(
              (id) => {
                "resourcesId": id,
                "resourceName": "",
                "isDeleted": false,
              },
            )
            .toList(),
      };
      try {
        final updated = await _spaceUnitProvider.update(
          _currentSpaceUnit!.spaceUnitId,
          request2,
        );
        setState(() {
          _currentSpaceUnit = updated;
        });
        await _loadImages();
        await _loadAllowedActions();
        showTopFlushBar(
          context: context,
          message: "Prostorna jedinica uspješno ažurirana",
          backgroundColor: Colors.green,
        );
      } catch (e) {
        String message = "Greška prilikom ažuriranja prostornih jedinica.";

        if (e is http.Response) {
          try {
            final errorJson = jsonDecode(e.body);
            if (errorJson["errors"] != null &&
                errorJson["errors"]["userError"] != null) {
              message = errorJson["errors"]["userError"][0];
            }
          } catch (_) {}
        }

        Flushbar(
          message: message,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
          borderRadius: BorderRadius.circular(8),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    } else {
      try {
        await _spaceUnitProvider.insert(request);
        await _showSuccessFlushbar("Prostorna jedinica uspješno kreirana.");
      } catch (e) {
        String message = "Greška prilikom kreiranja prostornih jedinica.";

        if (e is http.Response) {
          try {
            final errorJson = jsonDecode(e.body);
            if (errorJson["errors"] != null &&
                errorJson["errors"]["userError"] != null) {
              message = errorJson["errors"]["userError"][0];
            }
          } catch (_) {}
        }

        Flushbar(
          message: message,
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(10),
          borderRadius: BorderRadius.circular(8),
          flushbarPosition: FlushbarPosition.TOP,
        ).show(context);
      }
    }
  }

  void _clearForm() {
    _nameController.clear();
    _descriptionController.clear();
    _capacityController.clear();
    _priceController.clear();
    _selectedResourceIds.clear();
    _selectedImagesBytes.clear();
    _selectedWorkspaceType = null;

    setState(() {});
  }

  Future<void> _showSuccessFlushbar(String message) async {
    await Flushbar(
      message: message,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.green,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
    ).show(context);

    if (!isEdit) {
      _clearForm();
    }
  }

  Future<void> _showErrorFlushbar(String message) async {
    await Flushbar(
      message: message,
      duration: const Duration(seconds: 4),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
      margin: const EdgeInsets.all(8),
      borderRadius: BorderRadius.circular(8),
      icon: const Icon(Icons.error, color: Colors.white),
    ).show(context);
  }

  String parseServerError(dynamic error) {
    try {
      if (error is http.Response) {
        final errorJson = jsonDecode(error.body);

        if (errorJson["errors"] != null && errorJson["errors"] is Map) {
          final errorsMap = errorJson["errors"] as Map;

          if (errorsMap.isNotEmpty) {
            final firstKey = errorsMap.keys.first;
            final errorsList = errorsMap[firstKey];

            if (errorsList is List && errorsList.isNotEmpty) {
              return errorsList.first.toString();
            }
          }
        }

        if (errorJson["message"] != null) {
          return errorJson["message"].toString();
        }
      }
    } catch (_) {
      // ignore
    }

    return "Došlo je do greške. Pokušajte ponovo.";
  }

  Future<void> _confirmDelete() async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Potvrda brisanja"),
          content: const Text("Da li želite obrisati ovu prostorinu jedinicu?"),
          actions: [
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _spaceUnitProvider.delete(
                    _currentSpaceUnit!.spaceUnitId!,
                  );
                  await Flushbar(
                    message: "Prostorna jedinica uspješno obrisana!",
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 3),
                    flushbarPosition: FlushbarPosition.TOP,
                    margin: const EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(8),
                  ).show(context);

                  // vrati korisnika na WorkingSpaceDetailsScreen
                  widget.onChangeScreen(
                    WorkingSpaceDetailsScreen(
                      space: widget.space,
                      onChangeScreen: widget.onChangeScreen,
                    ),
                  );
                } catch (e) {
                  await Flushbar(
                    message: "Greška pri brisanju: ${parseServerError(e)}",
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 3),
                    flushbarPosition: FlushbarPosition.TOP,
                    margin: const EdgeInsets.all(8),
                    borderRadius: BorderRadius.circular(8),
                  ).show(context);
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Da", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Ne"),
            ),
          ],
        );
      },
    );
  }

  bool get isEditableForm {
    if (!isEdit) return true;
    return _currentSpaceUnit!.stateMachine.toLowerCase() == "draft";
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 28,
                onPressed: () {
                  widget.onChangeScreen(
                    WorkingSpaceDetailsScreen(
                      space: widget.space,
                      onChangeScreen: widget.onChangeScreen,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isEdit
                  ? "Uredi prostornu jedinicu"
                  : "Kreiraj novu prostornu jedinicu",
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: "Podaci"),
            Tab(text: "Slike"),
            Tab(text: "Recenzije"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildDataTab(), _buildImagesTab(), _buildReviewsTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildDataTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            _buildInput(
              _nameController,
              "Naziv",
              inputFormatters: [
                LengthLimitingTextInputFormatter(40),
                FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s\-]')),
              ],
            ),
            const SizedBox(height: 16),
            _buildInput(
              _descriptionController,
              "Opis",
              maxLines: 3,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
            ),
            const SizedBox(height: 16),
            _buildInput(
              _capacityController,
              "Kapacitet",
              keyboard: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
              ],
            ),
            const SizedBox(height: 16),
            _buildInput(
              _priceController,
              "Cijena po danu (KM)",
              keyboard: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(6),
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
            ),
            const SizedBox(height: 16),
            _loadingWorkspaceTypes
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<WorkspaceType>(
                    initialValue: _selectedWorkspaceType,

                    decoration: const InputDecoration(
                      labelText: "Tip prostora",
                      border: OutlineInputBorder(),
                    ),
                    items: _workspaceTypes.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.typeName),
                      );
                    }).toList(),
                    onChanged: isEditableForm
                        ? (value) =>
                              setState(() => _selectedWorkspaceType = value)
                        : null,
                    validator: (value) =>
                        value == null ? "Morate odabrati tip prostora" : null,
                  ),
            const SizedBox(height: 16),
            _loadingResources
                ? const Center(child: CircularProgressIndicator())
                : _buildResourceMultiSelect(),
            const SizedBox(height: 16),
            // ---- STATE MACHINE PRIKAZ ----
            if (isEdit)
              Row(
                children: [
                  Text(
                    "Trenutno stanje: ",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          stateColors[_currentSpaceUnit!.stateMachine
                              .toLowerCase()] ??
                          Colors.black,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _currentSpaceUnit!.stateMachine.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            if (isEdit)
              Wrap(
                spacing: 10,
                children: _allowedActions.map((action) {
                  Color buttonColor;

                  switch (action.toLowerCase()) {
                    case "activate":
                      buttonColor = Colors.green;
                      break;
                    case "delete":
                      buttonColor = Colors.red;
                      break;
                    case "hide":
                      buttonColor = Colors.grey;
                      break;
                    case "setmaintenance":
                      buttonColor = Colors.blue;
                      break;
                    case "edit":
                      buttonColor = Colors.orange;
                      break;
                    case "restore":
                      buttonColor = Colors.purple;
                      break;
                    default:
                      return const SizedBox.shrink();
                  }

                  return ElevatedButton(
                    onPressed: () async {
                      SpaceUnit updated;
                      switch (action.toLowerCase()) {
                        case "activate":
                          updated = await _spaceUnitProvider.activate(
                            _currentSpaceUnit!.spaceUnitId,
                          );
                          break;
                        case "hide":
                          updated = await _spaceUnitProvider.hide(
                            _currentSpaceUnit!.spaceUnitId,
                          );
                          break;
                        case "setmaintenance":
                          updated = await _spaceUnitProvider.setMaintenance(
                            _currentSpaceUnit!.spaceUnitId,
                          );
                          break;
                        case "restore":
                          updated = await _spaceUnitProvider.restore(
                            _currentSpaceUnit!.spaceUnitId,
                          );
                          break;
                        case "edit":
                          updated = await _spaceUnitProvider.edit(
                            _currentSpaceUnit!.spaceUnitId,
                          );
                          break;
                        case "delete":
                          _confirmDelete();
                          updated = _currentSpaceUnit!;
                          break;
                        default:
                          return;
                      }

                      setState(() {
                        _currentSpaceUnit = updated;
                      });
                      await _loadAllowedActions();
                      await _loadImages();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: buttonColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(80, 36),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      actionDisplayNames[action.toLowerCase()] ?? action,
                      style: const TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 150,
                height: 40,
                child: ElevatedButton(
                  onPressed: isEditableForm ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Sačuvaj",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if (isEditableForm)
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _pickImages,
                icon: const Icon(Icons.add_a_photo, color: Colors.white),
                label: const Text(
                  "Dodaj slike",
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: _loadingImages
                ? const Center(child: CircularProgressIndicator())
                : _images.isEmpty && _selectedImagesBytes.isEmpty
                ? const Center(
                    child: Text(
                      "Nema slika za prikaz",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1,
                        ),
                    itemCount: _images.length + _selectedImagesBytes.length,
                    itemBuilder: (_, index) {
                      bool isNetworkImage = index < _images.length;
                      Widget imageWidget;
                      if (isNetworkImage) {
                        final url =
                            "${BaseProvider.baseUrl}${_images[index].imagePath}";
                        imageWidget = Image.network(
                          url,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          },
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.broken_image),
                        );
                      } else {
                        final bytes =
                            _selectedImagesBytes[index - _images.length];
                        imageWidget = Image.memory(
                          bytes,
                          fit: BoxFit.cover,
                          gaplessPlayback: true,
                        );
                      }

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _openImageViewer(index);
                              },
                              child: imageWidget,
                            ),
                            if (isEditableForm)
                              Positioned(
                                top: 1,
                                right: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                      size: 30,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    onPressed: () async {
                                      bool? confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text("Potvrda brisanja"),
                                          content: const Text(
                                            "Da li ste sigurni da želite obrisati ovu sliku?",
                                          ),
                                          actions: [
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.blue,
                                              ),
                                              child: const Text(
                                                "Da",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text("Ne"),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm != true) return;

                                      try {
                                        if (isNetworkImage) {
                                          await _imageProvider.delete(
                                            _images[index].imageId!,
                                          );
                                          await _loadImages();
                                        } else {
                                          // Briši iz memorije (samo kreiranje)
                                          setState(() {
                                            _selectedImagesBytes.removeAt(
                                              index - _images.length,
                                            );
                                          });
                                        }

                                        showTopFlushBar(
                                          context: context,
                                          message: "Slika je obrisana",
                                          backgroundColor: Colors.green,
                                        );
                                      } catch (e) {
                                        showTopFlushBar(
                                          context: context,
                                          message:
                                              "Greška pri brisanju slike: $e",
                                          backgroundColor: Colors.red,
                                        );
                                      }
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsTab() {
    if (!isEdit) {
      return const Center(
        child: Text(
          "Recenzije su dostupne tek nakon kreiranja prostorne jedinice.",
          style: TextStyle(
            fontSize: 18,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return AdminReviewsTab(
      spaceUnitId: _currentSpaceUnit!.spaceUnitId!,
      highlightedReservationId: null,
    );
  }

  Widget _buildImageTile({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey.shade300,
      ),
      child: ClipRRect(borderRadius: BorderRadius.circular(8), child: child),
    );
  }

  Widget _buildInput(
    TextEditingController c,
    String label, {
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: c,
      maxLines: maxLines,
      maxLength: maxLength,
      readOnly: !isEditableForm,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return "$label je obavezan";

        if (label == "Naziv" && !RegExp(r'^[a-zA-Z0-9\s\-]+$').hasMatch(v)) {
          return "Naziv može sadržavati samo slova, brojeve i crticu (-)";
        }

        if (label == "Kapacitet" && int.tryParse(v) == null) {
          return "Kapacitet mora biti broj";
        }

        if (label == "Cijena po danu (KM)" && double.tryParse(v) == null) {
          return "Cijena mora biti broj";
        }

        return null;
      },
    );
  }

  Widget _buildResourceMultiSelect() {
    return FormField<List<int>>(
      initialValue: _selectedResourceIds,
      validator: (selected) {
        if (selected == null || selected.isEmpty) {
          return "Morate odabrati makar jedan resurs";
        }
        return null;
      },
      builder: (field) {
        bool hasError = field.hasError;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Resursi",
              style: TextStyle(
                fontSize: 16,
                color: hasError ? Colors.red[900] : Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(
                  color: hasError ? Colors.red[900]! : Colors.grey.shade400,
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Wrap(
                spacing: 10,
                children: _resources.map((r) {
                  bool selected = _selectedResourceIds.contains(r.resourcesId);
                  return FilterChip(
                    label: Text(
                      r.resourceName,
                      style: TextStyle(
                        color: hasError && !selected
                            ? Colors.red[900]
                            : Colors.black,
                      ),
                    ),
                    selected: selected,
                    onSelected: isEditableForm
                        ? (value) {
                            setState(() {
                              if (value)
                                _selectedResourceIds.add(r.resourcesId!);
                              else
                                _selectedResourceIds.remove(r.resourcesId);
                            });
                          }
                        : null,
                  );
                }).toList(),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  field.errorText!,
                  style: TextStyle(color: Colors.red[900], fontSize: 12),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _LocalImageViewer extends StatefulWidget {
  final List<SpaceUnitImage> networkImages; // slike sa servera
  final List<Uint8List> localImages; // slike iz memorije
  final int initialIndex;

  const _LocalImageViewer({
    required this.networkImages,
    required this.localImages,
    required this.initialIndex,
    super.key,
  });

  @override
  State<_LocalImageViewer> createState() => _LocalImageViewerState();
}

class _LocalImageViewerState extends State<_LocalImageViewer> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _next() {
    final total = widget.networkImages.length + widget.localImages.length;
    if (_currentIndex < total - 1) setState(() => _currentIndex++);
  }

  void _prev() {
    if (_currentIndex > 0) setState(() => _currentIndex--);
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.networkImages.length + widget.localImages.length;

    Widget imageWidget;
    if (_currentIndex < widget.networkImages.length) {
      final url =
          "${BaseProvider.baseUrl}${widget.networkImages[_currentIndex].imagePath}";
      imageWidget = Image.network(
        url,
        fit: BoxFit.contain,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (_, __, ___) =>
            const Icon(Icons.broken_image, color: Colors.white),
      );
    } else {
      final bytes =
          widget.localImages[_currentIndex - widget.networkImages.length];
      imageWidget = Image.memory(
        bytes,
        fit: BoxFit.contain,
        gaplessPlayback: true,
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "${_currentIndex + 1} / $total",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(child: imageWidget),
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: IconButton(
              iconSize: 48,
              color: Colors.white,
              icon: const Icon(Icons.arrow_back),
              onPressed: _prev,
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: IconButton(
              iconSize: 48,
              color: Colors.white,
              icon: const Icon(Icons.arrow_forward),
              onPressed: _next,
            ),
          ),
        ],
      ),
    );
  }
}

class AdminReviewsTab extends StatefulWidget {
  final int spaceUnitId;
  final int? highlightedReservationId;

  const AdminReviewsTab({
    super.key,
    required this.spaceUnitId,
    this.highlightedReservationId,
  });

  @override
  State<AdminReviewsTab> createState() => _AdminReviewsTabState();
}

class _AdminReviewsTabState extends State<AdminReviewsTab> {
  List<Review> reviews = [];
  bool loading = false;
  int page = 1;
  bool hasMore = true;
  final int pageSize = 10;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchReviews();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !loading &&
        hasMore) {
      page++;
      _fetchReviews();
    }
  }

  Future<void> _fetchReviews({bool reset = false}) async {
    if (loading) return;

    if (reset) {
      reviews.clear();
      page = 1;
      hasMore = true;
    }

    setState(() => loading = true);

    final ReviewProvider provider = ReviewProvider();

    final filter = {
      "SpaceUnitId": widget.spaceUnitId,
      "IncludeReservation": true,
      "Page": page,
      "PageSize": pageSize,
      "IsDeleted": false,
    };

    try {
      final result = await provider.get(filter: filter);

      setState(() {
        if (reset) {
          reviews = result.resultList;
        } else {
          reviews.addAll(result.resultList);
        }

        loading = false;
        if (result.resultList.length < pageSize) hasMore = false;
      });
    } catch (e) {
      setState(() => loading = false);
      showTopFlushBar(
        context: context,
        message: "Greška pri dohvaćanju recenzija: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return reviews.isEmpty && !loading
        ? const Center(
            child: Text(
              "Nema recenzija za prikaz",
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          )
        : ListView.separated(
            controller: _scrollController,
            itemCount: reviews.length + (hasMore ? 1 : 0),
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: Colors.grey),
            itemBuilder: (context, index) {
              if (index == reviews.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final r = reviews[index];
              final isHighlighted =
                  widget.highlightedReservationId != null &&
                  r.reservation?.reservationId ==
                      widget.highlightedReservationId;

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isHighlighted ? Colors.blue[50] : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: isHighlighted
                      ? Border.all(color: Colors.blue, width: 1.5)
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "${r.reservation?.users?.firstName} ${r.reservation?.users?.lastName}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "${r.createdAt.day}.${r.createdAt.month}.${r.createdAt.year}",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: List.generate(
                        5,
                        (i) => Icon(
                          i < r.rating ? Icons.star : Icons.star_border,
                          color: Colors.orange,
                          size: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(r.comment, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              );
            },
          );
  }
}

class ImageViewer extends StatefulWidget {
  final List<SpaceUnitImage> images;
  final int initialIndex;

  const ImageViewer({
    required this.images,
    required this.initialIndex,
    super.key,
  });

  @override
  State<ImageViewer> createState() => _ImageViewerState();
}

class _ImageViewerState extends State<ImageViewer> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _next() {
    if (_currentIndex < widget.images.length - 1)
      setState(() => _currentIndex++);
  }

  void _prev() {
    if (_currentIndex > 0) setState(() => _currentIndex--);
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl =
        "${BaseProvider.baseUrl}${widget.images[_currentIndex].imagePath}";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "${_currentIndex + 1} / ${widget.images.length}",
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 28),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, color: Colors.white, size: 50),
            ),
          ),
          Positioned(
            left: 16,
            top: 0,
            bottom: 0,
            child: IconButton(
              iconSize: 48,
              color: Colors.white,
              icon: const Icon(Icons.arrow_back),
              onPressed: _prev,
            ),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: IconButton(
              iconSize: 48,
              color: Colors.white,
              icon: const Icon(Icons.arrow_forward),
              onPressed: _next,
            ),
          ),
        ],
      ),
    );
  }
}

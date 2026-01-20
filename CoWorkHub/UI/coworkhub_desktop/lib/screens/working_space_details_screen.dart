import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:another_flushbar/flushbar.dart';
import 'package:coworkhub_desktop/models/space_unit.dart';
import 'package:coworkhub_desktop/models/working_space.dart';
import 'package:coworkhub_desktop/models/working_space_image.dart';
import 'package:coworkhub_desktop/models/workspace_type.dart';
import 'package:coworkhub_desktop/providers/base_provider.dart';
import 'package:coworkhub_desktop/providers/space_unit_provider.dart';
import 'package:coworkhub_desktop/providers/working_space_image_provider.dart';
import 'package:coworkhub_desktop/providers/workspace_type_provider.dart';
import 'package:coworkhub_desktop/screens/space_unit_form_screen.dart';
import 'package:coworkhub_desktop/screens/working_space_form_screen.dart';
import 'package:coworkhub_desktop/screens/working_space_screen.dart';
import 'package:coworkhub_desktop/utils/flushbar_helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class WorkingSpaceDetailsScreen extends StatefulWidget {
  final WorkingSpace space;
  final Function(Widget) onChangeScreen;

  const WorkingSpaceDetailsScreen({
    super.key,
    required this.space,
    required this.onChangeScreen,
  });

  @override
  State<WorkingSpaceDetailsScreen> createState() =>
      _WorkingSpaceDetailsScreenState();
}

class _WorkingSpaceDetailsScreenState extends State<WorkingSpaceDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final SpaceUnitProvider _spaceUnitProvider = SpaceUnitProvider();
  final WorkingSpaceImageProvider _imageProvider = WorkingSpaceImageProvider();
  final WorkspaceTypeProvider _workspaceTypeProvider = WorkspaceTypeProvider();

  List<SpaceUnit> _units = [];
  List<SpaceUnit> _filteredUnits = [];
  List<WorkingSpaceImage> _images = [];
  List<WorkspaceType> _workspaceTypes = [];

  int? filterCityId;
  int? filterWorkspaceTypeId;
  bool? filterIsDeleted;

  String _searchQuery = "";
  bool _loadingUnits = true;
  bool _loadingImages = true;
  int page = 1;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadUnitsWithFilters();
    _loadImages();
  }

  Future<void> _loadImages() async {
    setState(() => _loadingImages = true);
    try {
      var result = await _imageProvider.get(
        filter: {
          'WorkingSpaceId': widget.space.workingSpacesId,
          'IsDeleted': false,
        },
      );
      setState(() => _images = result.resultList);
    } catch (e) {
      debugPrint("Greška pri učitavanju slika: $e");
    } finally {
      setState(() => _loadingImages = false);
    }
  }

  Future<void> _loadUnitsWithFilters() async {
    setState(() => _loadingUnits = true);

    try {
      var workspaceTypeResult = await _workspaceTypeProvider.get(
        filter: {'RetrieveAll': true},
      );
      _workspaceTypes = workspaceTypeResult.resultList;

      Map<String, dynamic> filter = {
        'WorkingSpaceId': widget.space.workingSpacesId,
        'IncludeWorkspaceType': true,
        'IncludeAll': true,
        'RetrieveAll': true,
        'IsDeleted': false,
      };

      if (filterCityId != null) filter['CityId'] = filterCityId;
      if (filterWorkspaceTypeId != null)
        filter['WorkspaceTypeId'] = filterWorkspaceTypeId;
      if (filterIsDeleted != null) filter['IsDeleted'] = filterIsDeleted;

      var result = await _spaceUnitProvider.get(filter: filter);

      setState(() {
        _units = result.resultList;
        _filteredUnits = _units;
      });
    } catch (e) {
      debugPrint("Greška pri učitavanju space unita: $e");
    } finally {
      setState(() => _loadingUnits = false);
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

  Future<void> _pickAndUploadImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
      withData: true,
    );

    if (result == null) return;

    List<String> base64Images = [];
    for (var file in result.files) {
      Uint8List? bytes = file.bytes;
      if (bytes == null && file.path != null) {
        bytes = await File(file.path!).readAsBytes();
      }
      if (bytes != null) base64Images.add(base64Encode(bytes));
    }

    if (base64Images.isEmpty) {
      Flushbar(
        message: "Greška pri čitanju slike",
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
        flushbarPosition: FlushbarPosition.TOP,
        margin: const EdgeInsets.all(8),
        borderRadius: BorderRadius.circular(8),
      ).show(context);
      return;
    }

    try {
      await _imageProvider.uploadBase64Images(
        workingSpaceId: widget.space.workingSpacesId,
        base64Images: base64Images,
      );
      showTopFlushBar(
        context: context,
        message: "Slike uspješno dodane",
        backgroundColor: Colors.green,
      );
      await _loadImages();
    } catch (e) {
      showTopFlushBar(
        context: context,
        message: e.toString(),
        backgroundColor: Colors.green,
      );
    }
  }

  void _openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int? selectedCity = filterCityId;
        int? selectedWorkspaceType = filterWorkspaceTypeId;
        bool? selectedDeleted = filterIsDeleted ?? false;

        return AlertDialog(
          title: const Text("Filteri"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              // Tip prostora
              DropdownButtonFormField<int>(
                value: selectedWorkspaceType,
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text("Svi tipovi"),
                  ),
                  ..._workspaceTypes.map(
                    (w) => DropdownMenuItem(
                      value: w.workspaceTypeId,
                      child: Text(w.typeName ?? ""),
                    ),
                  ),
                ],
                onChanged: (v) => selectedWorkspaceType = v,
                decoration: const InputDecoration(labelText: "Tip prostora"),
              ),
              const SizedBox(height: 10),
              // Obrisani
              DropdownButtonFormField<bool?>(
                value: selectedDeleted,
                items: const [
                  DropdownMenuItem(value: null, child: Text("Svi")),
                  DropdownMenuItem(value: true, child: Text("Obrisani")),
                  DropdownMenuItem(value: false, child: Text("Neobrisani")),
                ],
                onChanged: (v) => selectedDeleted = v,
                decoration: const InputDecoration(labelText: "Obrisani"),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                filterCityId = selectedCity;
                filterWorkspaceTypeId = selectedWorkspaceType;
                filterIsDeleted = selectedDeleted;
                page = 1;
                _loadUnitsWithFilters();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Primijeni",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  selectedCity = null;
                  selectedWorkspaceType = null;
                  selectedDeleted = false;

                  filterCityId = null;
                  filterWorkspaceTypeId = null;
                  filterIsDeleted = false;
                  page = 1;
                });
                _loadUnitsWithFilters();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Resetiraj",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  widget.onChangeScreen(
                    WorkingSpacesScreen(onChangeScreen: widget.onChangeScreen),
                  );
                },
              ),
              const SizedBox(width: 8),
              Text(
                "${widget.space.name}",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: "Detalji"),
            Tab(text: "Prostorne jedinice"),
            Tab(text: "Slike"),
          ],
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              WorkingSpaceFormScreen(
                workspace: widget.space,
                onChangeScreen: widget.onChangeScreen,
              ),
              _buildSpaceUnitsTab(),
              _buildImagesTab(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpaceUnitsTab() {
    if (_loadingUnits) return const Center(child: CircularProgressIndicator());

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(
                    labelText: "Pretraga prostornih jedinica",
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                      _filteredUnits = _units.where((unit) {
                        final name = unit.name?.toLowerCase() ?? "";
                        final type =
                            unit.workspaceType?.typeName?.toLowerCase() ?? "";
                        return name.contains(_searchQuery) ||
                            type.contains(_searchQuery);
                      }).toList();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: _openFilterDialog,
                icon: const Icon(Icons.filter_list),
                label: const Text("Filteri"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () {
                  widget.onChangeScreen(
                    SpaceUnitFormScreen(
                      spaceUnit: null,
                      space: widget.space,
                      onChangeScreen: widget.onChangeScreen,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  "Dodaj jedinicu",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _filteredUnits.isEmpty
                  ? const Center(
                      child: Text(
                        "Nema podataka za prikaz",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredUnits.length,
                      itemBuilder: (_, index) {
                        final unit = _filteredUnits[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          elevation: 2,
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            title: Text(
                              unit.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text("Kapacitet: ${unit.capacity}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  unit.workspaceType?.typeName ?? "",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.blueGrey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 18,
                                ),
                              ],
                            ),
                            onTap: () {
                              widget.onChangeScreen(
                                SpaceUnitFormScreen(
                                  spaceUnit: unit,
                                  space: widget.space,
                                  onChangeScreen: widget.onChangeScreen,
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _pickAndUploadImage,
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
                : _images.isEmpty
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
                    itemCount: _images.length,
                    itemBuilder: (_, index) {
                      final img = _images[index];
                      final imageUrl =
                          "${BaseProvider.baseUrl}${img.imagePath}";

                      return ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            GestureDetector(
                              onTap: () => _openImageViewer(index),
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                loadingBuilder: (context, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                      child: Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                                    ),
                              ),
                            ),
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
                                    bool? confirm = await showDialog(
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

                                    if (confirm == true) {
                                      try {
                                        await _imageProvider.delete(
                                          img.imageId!,
                                        );
                                        showTopFlushBar(
                                          context: context,
                                          message: "Slika je obrisana",
                                          backgroundColor: Colors.green,
                                        );
                                        await _loadImages();
                                      } catch (e) {
                                        showTopFlushBar(
                                          context: context,
                                          message:
                                              "Greška pri brisanju slike: $e",
                                          backgroundColor: Colors.red,
                                        );
                                      }
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
}

class ImageViewer extends StatefulWidget {
  final List<WorkingSpaceImage> images;
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

import 'package:coworkhub_mobile/models/city.dart';
import 'package:coworkhub_mobile/models/space_unit.dart';
import 'package:coworkhub_mobile/models/workspace_type.dart';
import 'package:coworkhub_mobile/models/paged_result.dart';
import 'package:coworkhub_mobile/providers/base_provider.dart';
import 'package:coworkhub_mobile/providers/city_provider.dart';
import 'package:coworkhub_mobile/providers/recommender_provider.dart';
import 'package:coworkhub_mobile/providers/space_unit_provider.dart';
import 'package:coworkhub_mobile/providers/workspace_type_provider.dart';
import 'package:coworkhub_mobile/screens/space_unit_details_screen.dart';
import 'package:coworkhub_mobile/screens/space_unit_screen.dart';
import 'package:coworkhub_mobile/layout/layout_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _formKey = GlobalKey<FormState>();

  int? selectedCityId;
  int? selectedWorkspaceTypeId;
  String? selectedCityName;
  String? selectedWorkspaceTypeName;
  DateTimeRange? selectedDateRange;
  int peopleCount = 1;
  late TextEditingController _peopleController;
  bool _submitted = false;

  final dateFormat = DateFormat('dd.MM.yyyy');

  Future<PagedResult<City>>? _futureCities;
  Future<PagedResult<WorkspaceType>>? _futureSpaceTypes;

  @override
  void initState() {
    super.initState();
    _peopleController = TextEditingController(text: peopleCount.toString());
    _loadData();
  }

  void _loadData() {
    final cityProvider = Provider.of<CityProvider>(context, listen: false);
    final workspaceTypeProvider = Provider.of<WorkspaceTypeProvider>(
      context,
      listen: false,
    );

    var filter = {'RetrieveAll': true};
    _futureCities = cityProvider.get(filter: filter);
    _futureSpaceTypes = workspaceTypeProvider.get(filter: filter);
  }

  void pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2100, 12, 31),
      initialDateRange: selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        if (picked.end.isAtSameMomentAs(picked.start)) {
          selectedDateRange = DateTimeRange(
            start: picked.start,
            end: picked.start,
          );
        } else {
          selectedDateRange = picked;
        }
      });
    }
  }

  void search() {
    setState(() {
      _submitted = true;
    });

    if (_formKey.currentState!.validate() && selectedDateRange != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpaceUnitScreen(
            cityId: selectedCityId!,
            workspaceTypeId: selectedWorkspaceTypeId!,
            cityName: selectedCityName!,
            workspaceTypeName: selectedWorkspaceTypeName!,
            dateRange: selectedDateRange!,
            peopleCount: peopleCount,
          ),
        ),
      );
    }
  }

  InputDecoration getDefaultInputDecoration({
    required String label,
    required IconData icon,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: const OutlineInputBorder(),
      floatingLabelStyle: const TextStyle(fontSize: 16, color: Colors.black87),
      hintText: hintText,
      hintStyle: const TextStyle(fontSize: 16, color: Colors.grey),
    );
  }

  @override
  void dispose() {
    _peopleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          PreferredSize(
            preferredSize: const Size.fromHeight(80),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 43, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5,
                    offset: Offset(0, 1.5),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Početna',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
          // Scrollable sadržaj
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 10),
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Tip prostora
                            FutureBuilder<PagedResult<WorkspaceType>>(
                              future: _futureSpaceTypes,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const LinearProgressIndicator();
                                }

                                final data = snapshot.data?.resultList ?? [];

                                return DropdownButtonFormField<int>(
                                  initialValue: selectedWorkspaceTypeId,
                                  decoration: getDefaultInputDecoration(
                                    label: 'Tip prostora',
                                    icon: Icons.business_outlined,
                                  ),
                                  items: data
                                      .map(
                                        (e) => DropdownMenuItem<int>(
                                          value: e.workspaceTypeId,
                                          child: Text(e.typeName),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    final selected = data.firstWhere(
                                      (e) => e.workspaceTypeId == val,
                                    );
                                    setState(() {
                                      selectedWorkspaceTypeId = val;
                                      selectedWorkspaceTypeName =
                                          selected.typeName;
                                    });
                                  },
                                  validator: (value) => value == null
                                      ? 'Odaberite tip prostora'
                                      : null,
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Lokacija
                            FutureBuilder<PagedResult<City>>(
                              future: _futureCities,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const LinearProgressIndicator();
                                }

                                final data = snapshot.data?.resultList ?? [];

                                return DropdownButtonFormField<int>(
                                  initialValue: selectedCityId,
                                  decoration: getDefaultInputDecoration(
                                    label: 'Lokacija',
                                    icon: Icons.location_on_outlined,
                                  ),
                                  items: data
                                      .map(
                                        (e) => DropdownMenuItem<int>(
                                          value: e.cityId,
                                          child: Text(e.cityName),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    final selected = data.firstWhere(
                                      (e) => e.cityId == val,
                                    );
                                    setState(() {
                                      selectedCityId = val;
                                      selectedCityName = selected.cityName;
                                    });
                                  },
                                  validator: (value) => value == null
                                      ? 'Odaberite lokaciju'
                                      : null,
                                );
                              },
                            ),
                            const SizedBox(height: 16),

                            // Datum OD-DO
                            TextFormField(
                              readOnly: true,
                              controller: TextEditingController(
                                text: selectedDateRange == null
                                    ? ''
                                    : '${dateFormat.format(selectedDateRange!.start)} - ${dateFormat.format(selectedDateRange!.end)}',
                              ),
                              decoration: InputDecoration(
                                hintText: 'Odaberite datum',
                                labelText: selectedDateRange != null
                                    ? 'Datum'
                                    : null, // label samo kad je datum izabran
                                prefixIcon: const Icon(
                                  Icons.date_range_outlined,
                                ),
                                border: const OutlineInputBorder(),
                                errorText:
                                    _submitted && selectedDateRange == null
                                    ? 'Odaberite datum'
                                    : null,
                              ),
                              onTap: pickDateRange,
                            ),
                            const SizedBox(height: 16),

                            // Broj ljudi
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _peopleController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    keyboardType: TextInputType.number,
                                    decoration: getDefaultInputDecoration(
                                      label: 'Broj ljudi',
                                      icon: Icons.people_outlined,
                                    ),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                    ),
                                    validator: (val) {
                                      final parsed = int.tryParse(val ?? '');
                                      if (parsed == null ||
                                          parsed < 1 ||
                                          parsed > 10) {
                                        return 'Unesite broj između 1 i 10';
                                      }
                                      return null;
                                    },
                                    onChanged: (val) {
                                      final parsed = int.tryParse(val);
                                      if (parsed != null &&
                                          parsed >= 1 &&
                                          parsed <= 10) {
                                        setState(() => peopleCount = parsed);
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  children: [
                                    SizedBox(
                                      width: 36,
                                      height: 28,
                                      child: ElevatedButton(
                                        onPressed: peopleCount < 10
                                            ? () {
                                                setState(() {
                                                  peopleCount++;
                                                  _peopleController.text =
                                                      peopleCount.toString();
                                                });
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Icon(Icons.add, size: 16),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    SizedBox(
                                      width: 36,
                                      height: 28,
                                      child: ElevatedButton(
                                        onPressed: peopleCount > 1
                                            ? () {
                                                setState(() {
                                                  peopleCount--;
                                                  _peopleController.text =
                                                      peopleCount.toString();
                                                });
                                              }
                                            : null,
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Icon(
                                          Icons.remove,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Dugme za pretragu
                            SizedBox(
                              width: double.infinity,
                              height: 48,
                              child: ElevatedButton(
                                onPressed: search,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Pretraži',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Recommender
                    const SizedBox(height: 30),
                    const Text(
                      'Preporučeno za vas',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RecommendedSpaceUnitsWidget(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendedSpaceUnitsWidget extends StatefulWidget {
  const RecommendedSpaceUnitsWidget({Key? key}) : super(key: key);

  @override
  State<RecommendedSpaceUnitsWidget> createState() =>
      _RecommendedSpaceUnitsWidgetState();
}

class _RecommendedSpaceUnitsWidgetState
    extends State<RecommendedSpaceUnitsWidget> {
  List<SpaceUnit> units = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendedUnits();
  }

  Future<void> _loadRecommendedUnits() async {
    try {
      final recommender = RecommenderProvider();
      final spaceUnitProvider = Provider.of<SpaceUnitProvider>(
        context,
        listen: false,
      );

      final recommendations = await recommender.getRecommendations();

      final futures = recommendations.map((r) async {
        final result = await spaceUnitProvider.get(
          filter: {
            "SpaceUnitId": r.spaceUnitId,
            "IncludeImages": true,
            "IncludeWorkingSpace": true,
          },
        );
        return result.resultList.isNotEmpty ? result.resultList.first : null;
      });

      final results = await Future.wait(futures);
      setState(() {
        units = results.whereType<SpaceUnit>().toList();
        loading = false;
      });
    } catch (e) {
      print("Greška pri učitavanju preporuka: $e");
      setState(() {
        units = [];
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (units.isEmpty) {
      return const Center(child: Text("Trenutno nema preporuka za vas."));
    }

    return SizedBox(
      height: 270,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: units.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final su = units[index];
          return GestureDetector(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SpaceUnitDetailsScreen(
                    spaceUnitId: su.spaceUnitId,
                    showReservationControls: true,
                    dateRange: null,
                    peopleCount: 1,
                  ),
                ),
              );
              // if (mounted) {
              //   try {
              //     _layoutScreenState?.refreshLayout();
              //   } catch (e) {
              //     debugPrint("Greška pri osvježavanju layouta: $e");
              //   }
              // }
            },
            child: Container(
              width: 220,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    height: 140,
                    width: double.infinity,
                    child: su.spaceUnitImages.isNotEmpty
                        ? ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child: Image.network(
                              "${BaseProvider.baseUrl}${su.spaceUnitImages.first.imagePath}",
                              fit: BoxFit.cover,
                              errorBuilder: (c, o, s) =>
                                  const Icon(Icons.broken_image),
                            ),
                          )
                        : const Icon(Icons.image, size: 50),
                  ),
                  // Info
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          su.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          softWrap: true,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Lokacija: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: su.workingSpace!.city!.cityName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text.rich(
                          TextSpan(
                            children: [
                              const TextSpan(
                                text: "Kapacitet: ",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              TextSpan(
                                text: su.capacity.toString(),
                                style: const TextStyle(
                                  fontWeight: FontWeight.normal,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 4),
                        Text(
                          "${su.pricePerDay.toStringAsFixed(2)} KM / dan",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

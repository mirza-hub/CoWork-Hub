import 'package:coworkhub_mobile/models/city.dart';
import 'package:coworkhub_mobile/models/workspace_type.dart';
import 'package:coworkhub_mobile/models/paged_result.dart';
import 'package:coworkhub_mobile/providers/city_provider.dart';
import 'package:coworkhub_mobile/providers/workspace_type_provider.dart';
import 'package:coworkhub_mobile/screens/space_unit_screen.dart';
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
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: selectedDateRange,
    );

    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  void search() {
    setState(() {
      _submitted = true; // klikom na dugme označimo da se polja validiraju
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Početna',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 50),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // TIP PROSTORA
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
                              icon: Icons.business,
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
                                selectedWorkspaceTypeName = selected.typeName;
                              });
                            },
                            validator: (value) =>
                                value == null ? 'Odaberite tip prostora' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // LOKACIJA
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
                              icon: Icons.location_on,
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
                            validator: (value) =>
                                value == null ? 'Odaberite lokaciju' : null,
                          );
                        },
                      ),
                      const SizedBox(height: 16),

                      // DATUM OD-DO
                      TextFormField(
                        readOnly: true,
                        controller: TextEditingController(
                          text: selectedDateRange == null
                              ? ''
                              : '${dateFormat.format(selectedDateRange!.start)} - ${dateFormat.format(selectedDateRange!.end)}',
                        ),
                        decoration: InputDecoration(
                          hintText: 'Odaberite datum', // placeholder
                          labelText: selectedDateRange != null
                              ? 'Datum'
                              : null, // label samo kad je datum izabran
                          prefixIcon: const Icon(Icons.date_range),
                          border: const OutlineInputBorder(),
                          errorText: _submitted && selectedDateRange == null
                              ? 'Odaberite datum'
                              : null,
                        ),
                        onTap: pickDateRange,
                      ),
                      const SizedBox(height: 16),

                      // BROJ LJUDI
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
                                icon: Icons.people,
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
                                            _peopleController.text = peopleCount
                                                .toString();
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
                                            _peopleController.text = peopleCount
                                                .toString();
                                          });
                                        }
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                  ),
                                  child: const Icon(Icons.remove, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // DUGME ZA PRETRAGU
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
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

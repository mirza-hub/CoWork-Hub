import 'dart:async';
import 'package:intl/intl.dart';
import 'package:coworkhub_desktop/models/reservation.dart';
import 'package:coworkhub_desktop/providers/reservation_provider.dart';
import 'package:coworkhub_desktop/providers/space_unit_provider.dart';
import 'package:coworkhub_desktop/providers/user_provider.dart';
import 'package:flutter/material.dart';

class ReservationScreen extends StatefulWidget {
  final Function(Widget) onChangeScreen;

  const ReservationScreen({super.key, required this.onChangeScreen});

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  final TextEditingController _userFullName = TextEditingController();
  final TextEditingController _spaceUnitName = TextEditingController();

  final ReservationProvider _reservationProvider = ReservationProvider();
  final SpaceUnitProvider _spaceUnitProvider = SpaceUnitProvider();
  final UserProvider _userProvider = UserProvider();
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  List<Reservation> _reservations = [];

  int page = 1;
  int pageSize = 10;
  int totalPages = 1;
  String? sortColumn;
  String? sortDirection;
  Timer? _debounce;
  bool _isLoadingReservations = true;

  @override
  void initState() {
    super.initState();
    _userFullName.addListener(() {
      _onSearchChanged(_userFullName.text);
    });
    _spaceUnitName.addListener(() {
      _onSearchChanged(_spaceUnitName.text);
    });
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() {
      _isLoadingReservations = true;
    });
    final filter = {
      'IncludeUser': true,
      'IncludeSpaceUnit': true,
      'UserFullName': _userFullName.text,
      'SpaceUnitName': _spaceUnitName.text,
      'Page': page,
      'PageSize': pageSize,
      'SortColumn': sortColumn,
      'SortDirection': sortDirection,
    };
    final result = await _reservationProvider.get(filter: filter);
    setState(() {
      _reservations = result.resultList;
      totalPages = result.totalPages!;
      _isLoadingReservations = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SEARCH
          // Padding(
          // padding: const EdgeInsets.all(8.0),
          Row(
            children: [
              SizedBox(
                width: 240,
                height: 40,
                child: TextField(
                  controller: _userFullName,
                  decoration: InputDecoration(
                    labelText: "Korisnik",
                    labelStyle: TextStyle(
                      color: Colors.grey, // ← izgleda kao placeholder
                    ),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      // borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              // Expanded(
              //   child: TextField(
              //     decoration: const InputDecoration(labelText: "Naziv"),
              //     onChanged: (v) => searchName = v,
              //   ),
              // ),
              const SizedBox(width: 12),
              SizedBox(
                width: 240,
                height: 40,
                child: TextField(
                  controller: _spaceUnitName,
                  decoration: InputDecoration(
                    labelText: "Prostorna jedinica",
                    labelStyle: TextStyle(
                      color: Colors.grey, // ← izgleda kao placeholder
                    ),
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              // Expanded(
              //   child: TextField(
              //     decoration: const InputDecoration(labelText: "Adresa"),
              //     onChanged: (v) => searchAddress = v,
              //   ),
              // ),
              const SizedBox(width: 8),
              // ElevatedButton(
              //   onPressed: _openFilterDialog,
              //   child: const Text("Filter"),
              // ),
              ElevatedButton.icon(
                onPressed: () {
                  // _openFilterDialog();
                },
                icon: const Icon(Icons.filter_list),
                label: const Text("Filteri"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
              ),
              const Spacer(),
              // ElevatedButton.icon(
              //   onPressed: () {
              //     widget.onChangeScreen(
              //       WorkingSpaceFormScreen(
              //         workspace: null,
              //         onChangeScreen: widget.onChangeScreen,
              //       ),
              //     );
              //   },
              //   icon: const Icon(Icons.add),
              //   label: const Text("Kreiraj novi"),
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: const Color(0xFF3B82F6),
              //     foregroundColor: Colors.white,
              //     padding: const EdgeInsets.symmetric(
              //       horizontal: 20,
              //       vertical: 16,
              //     ),
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 20),

          // DATA TABLE
          Expanded(
            child: _isLoadingReservations
                ? const Center(child: CircularProgressIndicator())
                : _reservations.isEmpty
                ? const Center(
                    child: Text(
                      "Nema podataka za prikazivanje",
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : SingleChildScrollView(
                    child: DataTable(
                      headingRowColor: WidgetStateProperty.resolveWith<Color?>((
                        Set<WidgetState> states,
                      ) {
                        return const Color.fromARGB(255, 243, 242, 242);
                      }),
                      sortColumnIndex: sortColumn == "ReservationId"
                          ? 0
                          : sortColumn == "StateMachine"
                          ? 1
                          : null,
                      sortAscending: sortDirection == "asc",
                      columns: [
                        DataColumn(
                          label: const Text("ID"),
                          numeric: true,
                          onSort: (columnIndex, ascending) {
                            _onSort("ReservationId");
                          },
                        ),
                        DataColumn(label: const Text("Korisnik")),
                        DataColumn(label: const Text("Prostorna jedinica")),
                        DataColumn(label: const Text("Period")),
                        DataColumn(label: const Text("Broj osoba")),
                        DataColumn(label: const Text("Cijena")),
                        DataColumn(label: const Text("Status")),
                        DataColumn(label: const Text("Kreirano")),
                      ],
                      rows: _reservations
                          .map(
                            (r) => DataRow(
                              cells: [
                                DataCell(Text(r.reservationId.toString())),
                                DataCell(
                                  Text(
                                    "${r.users?.firstName ?? "-"} ${r.users?.lastName ?? "-"}",
                                  ),
                                ),
                                DataCell(Text(r.spaceUnit?.name ?? "-")),
                                DataCell(
                                  Text(
                                    "${_dateFormat.format(r.startDate)} - ${_dateFormat.format(r.endDate)}",
                                  ),
                                ),
                                DataCell(Text(r.peopleCount.toString())),
                                // DataCell(
                                //   Text(r.isDeleted == true ? "Ne" : "Da"),
                                // ),
                                DataCell(Text(r.totalPrice.toStringAsFixed(2))),
                                DataCell(Text(r.stateMachine)),
                                DataCell(
                                  Text(_dateFormat.format(r.createdAt!)),
                                ),

                                // DataCell(
                                //   Row(
                                //     children: [
                                //       IconButton(
                                //         onPressed: () {
                                //           widget.onChangeScreen(
                                //             WorkingSpaceDetailsScreen(
                                //               space: ws,
                                //               onChangeScreen:
                                //                   widget.onChangeScreen,
                                //             ),
                                //           );
                                //         },
                                //         icon: const Icon(Icons.info_outline),
                                //       ),
                                //       IconButton(
                                //         onPressed: () async {
                                //           bool?
                                //           confirm = await showDialog<bool>(
                                //             context: context,
                                //             builder: (context) => AlertDialog(
                                //               title: const Text(
                                //                 "Potvrda brisanja",
                                //               ),
                                //               content: const Text(
                                //                 "Da li želite obrisati ovaj zapis?",
                                //               ),
                                //               actions: [
                                //                 TextButton(
                                //                   onPressed: () =>
                                //                       Navigator.pop(
                                //                         context,
                                //                         true,
                                //                       ),
                                //                   child: const Text("Da"),
                                //                 ),
                                //                 TextButton(
                                //                   onPressed: () =>
                                //                       Navigator.pop(
                                //                         context,
                                //                         false,
                                //                       ),
                                //                   child: const Text("Ne"),
                                //                 ),
                                //               ],
                                //             ),
                                //           );

                                //           if (confirm == true) {
                                //             await provider.delete(
                                //               ws.workingSpacesId,
                                //             );
                                //             _loadSpaces();
                                //           }
                                //         },
                                //         icon: const Icon(
                                //           Icons.delete,
                                //           color: Colors.red,
                                //         ),
                                //       ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
          ),
          const Divider(
            color: Colors.grey, // ista boja kao header, možeš prilagoditi
            thickness: 1,
            height: 1,
          ),
          // PAGINATION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text("Prikaži:"),
                  const SizedBox(width: 10),
                  DropdownButton<int>(
                    value: pageSize,
                    items: const [
                      DropdownMenuItem(value: 10, child: Text("10")),
                      DropdownMenuItem(value: 20, child: Text("20")),
                      DropdownMenuItem(value: 50, child: Text("50")),
                    ],
                    onChanged: (v) {
                      pageSize = v!;
                      page = 1;
                      _loadReservations();
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: page > 1
                        ? () async {
                            setState(() => page--);
                            await _loadReservations();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    "${_reservations.isEmpty ? 0 : page} / ${totalPages == 0 ? 0 : totalPages}",
                  ),
                  IconButton(
                    onPressed: page < totalPages
                        ? () async {
                            setState(() => page++);
                            await _loadReservations();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // void _openFilterDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       int? selectedCity = filterCityId;
  //       bool? selectedDeleted = filterIsDeleted;
  //       return AlertDialog(
  //         title: const Text("Filteri"),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             DropdownButtonFormField<int>(
  //               value: selectedCity,
  //               items: [
  //                 const DropdownMenuItem(
  //                   value: null,
  //                   child: Text("Svi gradovi"),
  //                 ),
  //                 ...cities.map(
  //                   (c) => DropdownMenuItem(
  //                     value: c.cityId,
  //                     child: Text(c.cityName),
  //                   ),
  //                 ),
  //               ],
  //               onChanged: (v) => selectedCity = v,
  //               decoration: const InputDecoration(labelText: "Grad"),
  //             ),
  //             const SizedBox(height: 10),
  //             DropdownButtonFormField<bool>(
  //               value: selectedDeleted,
  //               items: const [
  //                 DropdownMenuItem(value: null, child: Text("Svi")),
  //                 DropdownMenuItem(value: false, child: Text("Neobrisani")),
  //                 DropdownMenuItem(value: true, child: Text("Obrisani")),
  //               ],
  //               onChanged: (v) => selectedDeleted = v,
  //               decoration: const InputDecoration(labelText: "Obrisan"),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           ElevatedButton(
  //             onPressed: () {
  //               filterCityId = selectedCity;
  //               filterIsDeleted = selectedDeleted;
  //               page = 1;
  //               _loadSpaces();
  //               Navigator.pop(context);
  //             },
  //             child: const Text("Primijeni"),
  //           ),
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text("Otkaži"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      page = 1;
      _loadReservations();
    });
  }

  void _onSort(String column) {
    if (sortColumn == column) {
      sortDirection = sortDirection == "asc" ? "desc" : "asc";
    } else {
      sortColumn = column;
      sortDirection = "asc";
    }
    _loadReservations();
  }

  @override
  void dispose() {
    _userFullName.dispose();
    _spaceUnitName.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}

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
  String? sortDirection = "asc";
  Timer? _debounce;
  bool _isLoadingReservations = true;

  final Map<int, String> _sortMap = {
    0: "ReservationId",
    3: "StartDate",
    4: "PeopleCount",
    5: "TotalPrice",
    6: "StateMachine",
    7: "CreatedAt",
  };

  DateTime? filterDateFrom;
  DateTime? filterDateTo;
  double? filterPriceFrom;
  double? filterPriceTo;
  int? filterPeopleFrom;
  int? filterPeopleTo;
  String? filterState;
  final stateOptions = ['All', 'Pending', 'Confirmed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _userFullName.addListener(() => _onSearchChanged(_userFullName.text));
    _spaceUnitName.addListener(() => _onSearchChanged(_spaceUnitName.text));
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    setState(() => _isLoadingReservations = true);

    final filter = {
      'IncludeUser': true,
      'IncludeSpaceUnit': true,
      'UserFullName': _userFullName.text,
      'SpaceUnitName': _spaceUnitName.text,
      'Page': page,
      'PageSize': pageSize,
      'SortColumn': sortColumn,
      'SortDirection': sortDirection,
      if (filterDateFrom != null) 'DateFrom': filterDateFrom!.toIso8601String(),
      if (filterDateTo != null) 'DateTo': filterDateTo!.toIso8601String(),
      if (filterPriceFrom != null) 'PriceFrom': filterPriceFrom,
      if (filterPriceTo != null) 'PriceTo': filterPriceTo,
      if (filterPeopleFrom != null) 'PeopleFrom': filterPeopleFrom,
      if (filterPeopleTo != null) 'PeopleTo': filterPeopleTo,
      if (filterState != null && filterState != 'All')
        'StateMachine': filterState,
    };

    try {
      final result = await _reservationProvider.get(filter: filter);
      setState(() {
        _reservations = result.resultList;
        totalPages = result.totalPages!;
      });
    } catch (e) {
      debugPrint("Greška pri učitavanju rezervacija: $e");
    } finally {
      setState(() => _isLoadingReservations = false);
    }
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      page = 1;
      _loadReservations();
    });
  }

  void _onSort(int columnIndex) {
    final backendColumn = _sortMap[columnIndex];
    if (backendColumn == null) return;

    if (sortColumn == backendColumn) {
      sortDirection = sortDirection == "asc" ? "desc" : "asc";
    } else {
      sortColumn = backendColumn;
      sortDirection = "asc";
    }

    page = 1;
    _loadReservations();
  }

  Widget _sortableHeader(String title, String columnKey) {
    Widget icon;

    if (sortColumn != columnKey) {
      icon = const Icon(Icons.unfold_more, size: 18, color: Colors.grey);
    } else {
      icon = Icon(
        sortDirection == "asc" ? Icons.arrow_upward : Icons.arrow_downward,
        size: 16,
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [Text(title), const SizedBox(width: 6), icon],
    );
  }

  void _openFilterDialog() {
    DateTime? tempDateFrom = filterDateFrom;
    DateTime? tempDateTo = filterDateTo;
    double? tempPriceFrom = filterPriceFrom;
    double? tempPriceTo = filterPriceTo;
    int? tempPeopleFrom = filterPeopleFrom;
    int? tempPeopleTo = filterPeopleTo;
    String? tempState = filterState ?? 'All';

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Filteri",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                InkWell(
                  child: const Icon(Icons.close, size: 22),
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            content: SizedBox(
              width: 320,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Datum od"),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: tempDateFrom ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null)
                          setDialogState(() => tempDateFrom = date);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tempDateFrom != null
                              ? DateFormat('dd/MM/yyyy').format(tempDateFrom!)
                              : "Odaberite datum",
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const Text("Datum do"),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: tempDateTo ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setDialogState(() => tempDateTo = date);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 8,
                        ),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          tempDateTo != null
                              ? DateFormat('dd/MM/yyyy').format(tempDateTo!)
                              : "Odaberite datum",
                          style: const TextStyle(color: Colors.black87),
                        ),
                      ),
                    ),
                    const Text("Cijena od"),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        hintText: "npr. 50.0",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (v) => setDialogState(
                        () => tempPriceFrom = double.tryParse(v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("Cijena do"),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        hintText: "npr. 200.0",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (v) => setDialogState(
                        () => tempPriceTo = double.tryParse(v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("Osobe od"),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "npr. 1",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (v) => setDialogState(
                        () => tempPeopleFrom = int.tryParse(v),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text("Osobe do"),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: "npr. 5",
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                      ),
                      onChanged: (v) =>
                          setDialogState(() => tempPeopleTo = int.tryParse(v)),
                    ),
                    const SizedBox(height: 12),
                    const Text("Status"),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: tempState,
                      items: stateOptions
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                      onChanged: (v) => setDialogState(() => tempState = v),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        filterDateFrom = tempDateFrom;
                        filterDateTo = tempDateTo;
                        filterPriceFrom = tempPriceFrom;
                        filterPriceTo = tempPriceTo;
                        filterPeopleFrom = tempPeopleFrom;
                        filterPeopleTo = tempPeopleTo;
                        filterState = tempState != 'All' ? tempState : null;
                        page = 1;
                        _loadReservations();
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
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        filterDateFrom = null;
                        filterDateTo = null;
                        filterPriceFrom = null;
                        filterPriceTo = null;
                        filterPeopleFrom = null;
                        filterPeopleTo = null;
                        filterState = null;
                        page = 1;
                        _loadReservations();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        "Resetiraj",
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  DataColumn _centeredColumn(Widget label, {void Function(int, bool)? onSort}) {
    return DataColumn(
      label: SizedBox(width: 120, child: Center(child: label)),
      onSort: onSort,
    );
  }

  DataCell _centeredCell(String text) {
    return DataCell(
      SizedBox(
        width: 120,
        child: Center(
          child: Text(text, textAlign: TextAlign.center, softWrap: true),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _userFullName.dispose();
    _spaceUnitName.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // SEARCH + FILTER
          Row(
            children: [
              SizedBox(
                width: 240,
                height: 40,
                child: TextField(
                  controller: _userFullName,
                  decoration: const InputDecoration(
                    labelText: "Korisnik",
                    prefixIcon: Icon(Icons.search),
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 240,
                height: 40,
                child: TextField(
                  controller: _spaceUnitName,
                  decoration: const InputDecoration(
                    labelText: "Prostorna jedinica",
                    prefixIcon: Icon(Icons.search),
                    labelStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
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
            ],
          ),
          const SizedBox(height: 20),
          // Tabela
          Expanded(
            child: _isLoadingReservations
                ? const Center(child: CircularProgressIndicator())
                : _reservations.isEmpty
                ? const Center(
                    child: Text(
                      "Nema podataka za prikazivanje",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      return SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: SizedBox(
                            width: constraints.maxWidth,
                            child: DataTable(
                              headingRowHeight: 50,
                              dataRowHeight: 48,
                              columnSpacing: 0,
                              horizontalMargin: 0,
                              headingRowColor:
                                  MaterialStateProperty.resolveWith<Color?>(
                                    (states) => const Color.fromARGB(
                                      255,
                                      243,
                                      242,
                                      242,
                                    ),
                                  ),
                              sortColumnIndex: sortColumn != null
                                  ? _sortMap.entries
                                        .firstWhere(
                                          (e) => e.value == sortColumn,
                                          orElse: () => const MapEntry(0, ""),
                                        )
                                        .key
                                  : null,
                              sortAscending: sortDirection == "asc",
                              columns: [
                                _centeredColumn(
                                  _sortableHeader("ID", "ReservationId"),
                                  onSort: (i, _) => _onSort(0),
                                ),
                                _centeredColumn(const Text("Korisnik")),
                                _centeredColumn(
                                  const Text("Prostorna jedinica"),
                                ),
                                _centeredColumn(
                                  _sortableHeader("Period", "StartDate"),
                                  onSort: (i, _) => _onSort(3),
                                ),
                                _centeredColumn(
                                  _sortableHeader("Količina", "PeopleCount"),
                                  onSort: (i, _) => _onSort(4),
                                ),
                                _centeredColumn(
                                  _sortableHeader("Cijena", "TotalPrice"),
                                  onSort: (i, _) => _onSort(5),
                                ),
                                _centeredColumn(
                                  _sortableHeader("Status", "StateMachine"),
                                  onSort: (i, _) => _onSort(6),
                                ),
                                _centeredColumn(
                                  _sortableHeader("Kreirano", "CreatedAt"),
                                  onSort: (i, _) => _onSort(7),
                                ),
                              ],
                              rows: _reservations
                                  .map(
                                    (r) => DataRow(
                                      cells: [
                                        _centeredCell(
                                          r.reservationId.toString(),
                                        ),
                                        _centeredCell(
                                          "${r.users?.firstName ?? "-"} ${r.users?.lastName ?? "-"}",
                                        ),
                                        _centeredCell(r.spaceUnit?.name ?? "-"),
                                        _centeredCell(
                                          "${_dateFormat.format(r.startDate)} - ${_dateFormat.format(r.endDate)}",
                                        ),
                                        _centeredCell(r.peopleCount.toString()),
                                        _centeredCell(
                                          r.totalPrice.toStringAsFixed(2),
                                        ),
                                        _centeredCell(r.stateMachine),
                                        _centeredCell(
                                          _dateFormat.format(r.createdAt!),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          // Footer
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
                      DropdownMenuItem(value: 5, child: Text("5")),
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
                        ? () {
                            setState(() => page--);
                            _loadReservations();
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text("$page / ${totalPages == 0 ? 0 : totalPages}"),
                  IconButton(
                    onPressed: page < totalPages
                        ? () {
                            setState(() => page++);
                            _loadReservations();
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
}

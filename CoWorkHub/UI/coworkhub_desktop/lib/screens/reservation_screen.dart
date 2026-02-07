import 'dart:async';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:coworkhub_desktop/models/reservation.dart';
import 'package:coworkhub_desktop/providers/reservation_provider.dart';
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
  final DateFormat _dateFormat = DateFormat('dd/MM/yyyy');

  List<Reservation> _reservations = [];

  int page = 1;
  int pageSize = 10;
  int totalPages = 1;
  int totalCount = 0;
  String? sortColumn;
  String? sortDirection = "asc";
  Timer? _debounce;
  bool _isLoadingReservations = true;

  DateTime? filterDateFrom;
  DateTime? filterDateTo;
  double? filterPriceFrom;
  double? filterPriceTo;
  int? filterPeopleFrom;
  int? filterPeopleTo;
  String? filterState;
  final stateOptions = ['All', 'Pending', 'Confirmed', 'Canceled', 'Completed'];
  final Map<String, String> _stateLabels = const {
    'All': 'Svi',
    'Pending': 'Na čekanju',
    'Confirmed': 'Potvrđeno',
    'Canceled': 'Otkazano',
    'Completed': 'Završeno',
  };

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
      final result = await _reservationProvider.get(
        filter: filter,
        page: page,
        pageSize: pageSize,
        orderBy: sortColumn,
        sortDirection: sortDirection,
      );
      setState(() {
        _reservations = result.resultList;
        totalPages = result.totalPages!;
        totalCount = result.count ?? 0;
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

  void _onSortBy(String columnKey) {
    if (sortColumn == columnKey) {
      sortDirection = sortDirection == "asc" ? "desc" : "asc";
    } else {
      sortColumn = columnKey;
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
    final dateFromController = TextEditingController(
      text: tempDateFrom != null
          ? DateFormat('dd/MM/yyyy').format(tempDateFrom)
          : "",
    );
    final dateToController = TextEditingController(
      text: tempDateTo != null
          ? DateFormat('dd/MM/yyyy').format(tempDateTo)
          : "",
    );
    final priceFromController = TextEditingController(
      text: tempPriceFrom?.toString() ?? "",
    );
    final priceToController = TextEditingController(
      text: tempPriceTo?.toString() ?? "",
    );
    final peopleFromController = TextEditingController(
      text: tempPeopleFrom?.toString() ?? "",
    );
    final peopleToController = TextEditingController(
      text: tempPeopleTo?.toString() ?? "",
    );

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
                    TextField(
                      controller: dateFromController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Datum od",
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: tempDateFrom ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setDialogState(() {
                            tempDateFrom = date;
                            dateFromController.text = DateFormat(
                              'dd/MM/yyyy',
                            ).format(date);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: dateToController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Datum do",
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(),
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: tempDateTo ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          setDialogState(() {
                            tempDateTo = date;
                            dateToController.text = DateFormat(
                              'dd/MM/yyyy',
                            ).format(date);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceFromController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Cijena od (KM)",
                        prefixIcon: Icon(Icons.attach_money_outlined),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setDialogState(
                        () => tempPriceFrom = double.tryParse(v),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: priceToController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Cijena do (KM)",
                        prefixIcon: Icon(Icons.attach_money_outlined),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setDialogState(
                        () => tempPriceTo = double.tryParse(v),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: peopleFromController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Osobe od",
                        prefixIcon: Icon(Icons.people_outlined),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) => setDialogState(
                        () => tempPeopleFrom = int.tryParse(v),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: peopleToController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(6),
                      ],
                      decoration: const InputDecoration(
                        labelText: "Osobe do",
                        prefixIcon: Icon(Icons.people_outlined),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) =>
                          setDialogState(() => tempPeopleTo = int.tryParse(v)),
                    ),
                    const SizedBox(height: 10),
                    const Text("Status"),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: tempState,
                      items: stateOptions
                          .map(
                            (s) => DropdownMenuItem(
                              value: s,
                              child: Text(_stateLabels[s] ?? s),
                            ),
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

  Widget buildReservationStatus(String state) {
    late String text;
    late Color color;

    switch (state.toLowerCase()) {
      case "pending":
        text = "NA ČEKANJU";
        color = Colors.orange;
        break;
      case "confirmed":
        text = "POTVRĐENO";
        color = Colors.blueAccent;
        break;
      case "canceled":
        text = "OTKAZANO";
        color = Colors.red;
        break;
      case "completed":
        text = "ZAVRŠENO";
        color = Colors.green;
        break;
      default:
        text = state.toUpperCase();
        color = Colors.grey;
    }

    return Container(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
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
                              columns: [
                                _centeredColumn(
                                  _sortableHeader("ID", "ReservationId"),
                                  onSort: (i, _) => _onSortBy("ReservationId"),
                                ),
                                _centeredColumn(const Text("Korisnik")),
                                _centeredColumn(
                                  const Text("Prostorna jedinica"),
                                ),
                                _centeredColumn(
                                  _sortableHeader("Period", "StartDate"),
                                  onSort: (i, _) => _onSortBy("StartDate"),
                                ),
                                _centeredColumn(const Text("Broj ljudi")),
                                _centeredColumn(
                                  _sortableHeader("Cijena", "TotalPrice"),
                                  onSort: (i, _) => _onSortBy("TotalPrice"),
                                ),
                                _centeredColumn(
                                  _sortableHeader("Status", "StateMachine"),
                                  onSort: (i, _) => _onSortBy("StateMachine"),
                                ),
                                // _centeredColumn(
                                //   _sortableHeader("Kreirano", "CreatedAt"),
                                //   onSort: (i, _) => _onSortBy("CreatedAt"),
                                // ),
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
                                          "${r.totalPrice.toStringAsFixed(2)} KM",
                                        ),
                                        DataCell(
                                          SizedBox(
                                            width: 120,
                                            child: Center(
                                              child: buildReservationStatus(
                                                r.stateMachine,
                                              ),
                                            ),
                                          ),
                                        ),
                                        // _centeredCell(
                                        //   _dateFormat.format(r.createdAt!),
                                        // ),
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
                  Text(
                    totalCount == 0
                        ? "0 od 0"
                        : "${((page - 1) * pageSize) + 1}–${((page - 1) * pageSize) + _reservations.length} od $totalCount",
                  ),
                  const SizedBox(width: 16),
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

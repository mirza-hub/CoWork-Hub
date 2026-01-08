import 'package:coworkhub_mobile/screens/payment_method_screen.dart';
import 'package:coworkhub_mobile/screens/space_unit_details_screen.dart';
import 'package:coworkhub_mobile/utils/flushbar_helper.dart';
import 'package:coworkhub_mobile/utils/format_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:coworkhub_mobile/models/reservation.dart';
import 'package:coworkhub_mobile/providers/reservation_provider.dart';
import 'package:coworkhub_mobile/providers/auth_provider.dart';

class ReservationsScreen extends StatefulWidget {
  const ReservationsScreen({super.key});

  @override
  State<ReservationsScreen> createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  List<Reservation> reservations = [];
  bool loading = false;
  int totalCount = 0;
  DateTime? filterDateFrom;
  DateTime? filterDateTo;
  double? filterPriceFrom;
  double? filterPriceTo;
  int? filterPeopleFrom;
  int? filterPeopleTo;
  int page = 1;
  String orderBy = "CreatedAt";
  String sortDirection = "DESC";
  String searchText = "";
  bool hasMore = true;
  String? stateFilter = "all";

  late ScrollController _scrollController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchReservations();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !loading &&
          hasMore) {
        page++;
        fetchReservations();
      }
    });
  }

  Future<void> fetchReservations({bool reset = false}) async {
    if (loading) return;

    if (reset) {
      reservations.clear();
      page = 1;
      hasMore = true;
    }

    setState(() => loading = true);

    final provider = context.read<ReservationProvider>();

    final filter = {
      "UserId": AuthProvider.userId,
      "SpaceUnitName": searchText,
      "IncludeUser": true,
      "IncludeSpaceUnit": true,
      "OrderBy": orderBy,
      "SortDirection": sortDirection,
      "OnlyActive": true,
      "Page": page,
      "PageSize": 10,
    };

    if (filterDateFrom != null) {
      filter["DateFrom"] = filterDateFrom!.toIso8601String();
    }

    if (stateFilter != "all") {
      filter["StateMachine"] = stateFilter;
    }

    if (filterDateTo != null) {
      filter["DateTo"] = filterDateTo!.toIso8601String();
    }

    if (filterPriceFrom != null) {
      filter["PriceFrom"] = filterPriceFrom;
    }

    if (filterPriceTo != null) {
      filter["PriceTo"] = filterPriceTo;
    }

    if (filterPeopleFrom != null) {
      filter["PeopleFrom"] = filterPeopleFrom;
    }

    if (filterPeopleTo != null) {
      filter["PeopleTo"] = filterPeopleTo;
    }

    final result = await provider.get(filter: filter);

    setState(() {
      if (reset) {
        reservations = result.resultList;
      } else {
        reservations.addAll(result.resultList);
      }

      totalCount = result.count!;
      loading = false;

      if (reservations.length >= totalCount) {
        hasMore = false;
      }
    });
  }

  void showSortOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // ovo je ključno
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sortiraj po",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  RadioListTile(
                    title: const Text("Datum kreiranja — novo prvo"),
                    value: "CreatedAt_DESC",
                    groupValue: "$orderBy\_$sortDirection",
                    onChanged: (_) {
                      setModalState(() {
                        orderBy = "CreatedAt";
                        sortDirection = "DESC";
                      });
                    },
                  ),

                  RadioListTile(
                    title: const Text("Datum kreiranja — starije prvo"),
                    value: "CreatedAt_ASC",
                    groupValue: "$orderBy\_$sortDirection",
                    onChanged: (_) {
                      setModalState(() {
                        orderBy = "CreatedAt";
                        sortDirection = "ASC";
                      });
                    },
                  ),

                  RadioListTile(
                    title: const Text("Početak rezervacije — ranije prvo"),
                    value: "StartDate_ASC",
                    groupValue: "$orderBy\_$sortDirection",
                    onChanged: (_) {
                      setModalState(() {
                        orderBy = "StartDate";
                        sortDirection = "ASC";
                      });
                    },
                  ),

                  RadioListTile(
                    title: const Text("Početak rezervacije — kasnije prvo"),
                    value: "StartDate_DESC",
                    groupValue: "$orderBy\_$sortDirection",
                    onChanged: (_) {
                      setModalState(() {
                        orderBy = "StartDate";
                        sortDirection = "DESC";
                      });
                    },
                  ),

                  RadioListTile(
                    title: const Text("Ukupna cijena — manja prema većoj"),
                    value: "TotalPrice_ASC",
                    groupValue: "$orderBy\_$sortDirection",
                    onChanged: (_) {
                      setModalState(() {
                        orderBy = "TotalPrice";
                        sortDirection = "ASC";
                      });
                    },
                  ),

                  RadioListTile(
                    title: const Text("Ukupna cijena — veća prema manjoj"),
                    value: "TotalPrice_DESC",
                    groupValue: "$orderBy\_$sortDirection",
                    onChanged: (_) {
                      setModalState(() {
                        orderBy = "TotalPrice";
                        sortDirection = "DESC";
                      });
                    },
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      // Dugme Primijeni
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            fetchReservations(reset: true);
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

                      const SizedBox(width: 10), // mali razmak
                      // Prazna polovina
                      const Expanded(child: SizedBox.shrink()),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showFilterOptions() {
    // privremene varijable za sheet
    DateTime? tempDateFrom = filterDateFrom;
    DateTime? tempDateTo = filterDateTo;
    double? tempPriceFrom = filterPriceFrom;
    double? tempPriceTo = filterPriceTo;
    int? tempPeopleFrom = filterPeopleFrom;
    int? tempPeopleTo = filterPeopleTo;
    String? tempStateFilter = stateFilter;

    // kontroleri za inpute
    final dateFromController = TextEditingController(
      text: tempDateFrom != null ? formatDate(tempDateFrom) : '',
    );
    final dateToController = TextEditingController(
      text: tempDateTo != null ? formatDate(tempDateTo) : '',
    );
    final priceFromController = TextEditingController(
      text: tempPriceFrom?.toString() ?? '',
    );
    final priceToController = TextEditingController(
      text: tempPriceTo?.toString() ?? '',
    );
    final peopleFromController = TextEditingController(
      text: tempPeopleFrom?.toString() ?? '',
    );
    final peopleToController = TextEditingController(
      text: tempPeopleTo?.toString() ?? '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filtriraj",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // DATUM OD
                  TextFormField(
                    readOnly: true,
                    controller: dateFromController,
                    decoration: InputDecoration(
                      labelText: 'Datum od',
                      prefixIcon: const Icon(Icons.date_range_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempDateFrom ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() {
                          tempDateFrom = picked;
                          dateFromController.text = formatDate(picked);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),

                  // DATUM DO
                  TextFormField(
                    readOnly: true,
                    controller: dateToController,
                    decoration: InputDecoration(
                      labelText: 'Datum do',
                      prefixIcon: const Icon(Icons.date_range_outlined),
                      border: const OutlineInputBorder(),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: tempDateTo ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setModalState(() {
                          tempDateTo = picked;
                          dateToController.text = formatDate(picked);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    initialValue: tempStateFilter,
                    decoration: const InputDecoration(
                      labelText: "Status rezervacije",
                      prefixIcon: Icon(Icons.label_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "all",
                        child: Text(
                          "Sve",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                      DropdownMenuItem(
                        value: "pending",
                        child: Text("Na čekanju"),
                      ),
                      DropdownMenuItem(
                        value: "confirmed",
                        child: Text("Potvrđeno"),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        tempStateFilter = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  // CIJENA OD
                  TextField(
                    controller: priceFromController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      labelText: "Cijena od (KM)",
                      prefixIcon: Icon(Icons.attach_money_outlined),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => tempPriceFrom = double.tryParse(v),
                  ),
                  const SizedBox(height: 10),

                  // CIJENA DO
                  TextField(
                    controller: priceToController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      labelText: "Cijena do (KM)",
                      prefixIcon: Icon(Icons.attach_money_outlined),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => tempPriceTo = double.tryParse(v),
                  ),
                  const SizedBox(height: 10),

                  // BROJ OSOBA OD
                  TextField(
                    controller: peopleFromController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      labelText: "Broj osoba od",
                      prefixIcon: Icon(Icons.people_outlined),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => tempPeopleFrom = int.tryParse(v),
                  ),
                  const SizedBox(height: 10),

                  // BROJ OSOBA DO
                  TextField(
                    controller: peopleToController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      labelText: "Broj osoba do",
                      prefixIcon: Icon(Icons.people_outlined),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (v) => tempPeopleTo = int.tryParse(v),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      // PRIMIJENI
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              filterDateFrom = tempDateFrom;
                              filterDateTo = tempDateTo;
                              filterPriceFrom = tempPriceFrom;
                              filterPriceTo = tempPriceTo;
                              filterPeopleFrom = tempPeopleFrom;
                              filterPeopleTo = tempPeopleTo;
                              stateFilter = tempStateFilter;
                            });
                            Navigator.pop(context);
                            fetchReservations(reset: true);
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
                      // RESETIRAJ
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setModalState(() {
                              tempDateFrom = null;
                              tempDateTo = null;
                              tempPriceFrom = null;
                              tempPriceTo = null;
                              tempPeopleFrom = null;
                              tempPeopleTo = null;
                              tempStateFilter = "all";

                              // očisti inpute odmah
                              dateFromController.text = '';
                              dateToController.text = '';
                              priceFromController.text = '';
                              priceToController.text = '';
                              peopleFromController.text = '';
                              peopleToController.text = '';
                            });

                            setState(() {
                              filterDateFrom = null;
                              filterDateTo = null;
                              filterPriceFrom = null;
                              filterPriceTo = null;
                              filterPeopleFrom = null;
                              filterPeopleTo = null;
                              stateFilter = "all";

                              reservations.clear();
                              page = 1;
                            });

                            Navigator.pop(context);
                            fetchReservations(reset: true);
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
              ),
            );
          },
        );
      },
    );
  }

  Future<bool?> showCancelConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Potvrda otkazivanja"),
          content: const Text(
            "Da li ste sigurni da želite otkazati ovu rezervaciju?",
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Da", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text("Ne"),
            ),
          ],
        );
      },
    );
  }

  bool canCancelReservation(DateTime startDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);

    final daysUntilStart = start.difference(today).inDays;

    return daysUntilStart >= 3;
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
        color = Colors.green;
        break;
      default:
        text = state.toUpperCase();
        color = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(top: 6),
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
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 43, 16, 5),
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
            child: Column(
              children: [
                const Text(
                  'Rezervacije',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: "Pretraži rezervacije...",
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      searchText = value;
                      fetchReservations(reset: true);
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: showSortOptions,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sort),
                              SizedBox(width: 6),
                              Text("Sortiraj"),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: showFilterOptions,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.filter_list),
                              SizedBox(width: 6),
                              Text("Filtriraj"),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          if (!loading && reservations.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                "Prikazano ${reservations.length} od $totalCount rezervacija",
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),

          /// LISTA
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : reservations.isEmpty
                ? const Center(
                    child: Text(
                      "Nema rezervacija",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    key: const PageStorageKey('reservationsList'),
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: reservations.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == reservations.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final reservation = reservations[index];
                      final su = reservation.spaceUnit!;

                      final canCancel = canCancelReservation(
                        reservation.startDate.toLocal(),
                      );
                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SpaceUnitDetailsScreen(
                                spaceUnitId: su.spaceUnitId,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(
                            16,
                            index == 0 ? 0 : 8,
                            16,
                            8,
                          ),
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // IMAGE
                              SizedBox(
                                width: 110,
                                height: 240,
                                child: su.spaceUnitImages.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                              left: Radius.circular(12),
                                            ),
                                        child: Image.network(
                                          su.spaceUnitImages.first.imagePath,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                    : const Icon(Icons.image, size: 30),
                              ),

                              // INFO
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        su.name,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Od ${formatDate(reservation.startDate.toLocal())} "
                                        "- ${formatDate(reservation.endDate.toLocal())}",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      buildReservationStatus(
                                        reservation.stateMachine,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Osoba: ${reservation.peopleCount}",
                                        style: const TextStyle(fontSize: 13),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        "${reservation.totalPrice.toStringAsFixed(2)} KM",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),
                                      const SizedBox(height: 10),

                                      // DUGMAD
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          children: [
                                            // PLATI - samo ako je pending, inače nevidljivo ali zauzima prostor
                                            Expanded(
                                              child: Visibility(
                                                visible:
                                                    reservation.stateMachine
                                                        .toLowerCase() ==
                                                    "pending",
                                                maintainSize: true,
                                                maintainAnimation: true,
                                                maintainState: true,
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    final result = await Navigator.push<bool>(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) => PaymentMethodScreen(
                                                          spaceUnit: reservation
                                                              .spaceUnit!,
                                                          dateRange:
                                                              DateTimeRange(
                                                                start: reservation
                                                                    .startDate
                                                                    .toLocal(),
                                                                end: reservation
                                                                    .endDate
                                                                    .toLocal(),
                                                              ),
                                                          peopleCount:
                                                              reservation
                                                                  .peopleCount,
                                                          reservationId:
                                                              reservation
                                                                  .reservationId,
                                                        ),
                                                      ),
                                                    );

                                                    if (result == true) {
                                                      showTopFlushBar(
                                                        context: context,
                                                        message:
                                                            "Plaćanje uspješno!",
                                                        backgroundColor:
                                                            Colors.green,
                                                      );

                                                      fetchReservations(
                                                        reset: true,
                                                      );
                                                    } else if (result ==
                                                        false) {
                                                      showTopFlushBar(
                                                        context: context,
                                                        message:
                                                            "Plaćanje nije uspješno ili je otkazano",
                                                        backgroundColor:
                                                            Colors.red,
                                                      );
                                                    }
                                                  },

                                                  style: ElevatedButton.styleFrom(
                                                    minimumSize: const Size(
                                                      0,
                                                      44,
                                                    ),
                                                    backgroundColor:
                                                        Colors.green,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "Plati",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            // OTKAŽI
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: canCancel
                                                    ? () async {
                                                        final confirmed =
                                                            await showCancelConfirmationDialog(
                                                              context,
                                                            );
                                                        if (confirmed != true)
                                                          return;

                                                        try {
                                                          await context
                                                              .read<
                                                                ReservationProvider
                                                              >()
                                                              .cancel(
                                                                reservation
                                                                    .reservationId,
                                                              );

                                                          showTopFlushBar(
                                                            context: context,
                                                            message:
                                                                "Rezervacija je uspješno otkazana",
                                                            backgroundColor:
                                                                Colors.green,
                                                          );

                                                          fetchReservations(
                                                            reset: true,
                                                          );
                                                        } catch (e) {
                                                          showTopFlushBar(
                                                            context: context,
                                                            message: e
                                                                .toString(),
                                                            backgroundColor:
                                                                Colors.red,
                                                          );
                                                        }
                                                      }
                                                    : null,
                                                style: ElevatedButton.styleFrom(
                                                  minimumSize: const Size(
                                                    0,
                                                    44,
                                                  ),
                                                  backgroundColor: Colors.red,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Otkaži",
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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

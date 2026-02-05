import 'package:coworkhub_mobile/providers/base_provider.dart';
import 'package:coworkhub_mobile/screens/review_form_screen.dart';
import 'package:coworkhub_mobile/screens/space_unit_details_screen.dart';
import 'package:coworkhub_mobile/utils/flushbar_helper.dart';
import 'package:coworkhub_mobile/utils/format_date.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:coworkhub_mobile/models/reservation.dart';
import 'package:coworkhub_mobile/providers/reservation_provider.dart';
import 'package:coworkhub_mobile/providers/auth_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
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
  String? stateFilter = "completed";

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
      "OnlyInactive": true,
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
                mainAxisSize: MainAxisSize.min,
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

                      const SizedBox(width: 10),
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
    DateTime? tempDateFrom = filterDateFrom;
    DateTime? tempDateTo = filterDateTo;
    double? tempPriceFrom = filterPriceFrom;
    double? tempPriceTo = filterPriceTo;
    int? tempPeopleFrom = filterPeopleFrom;
    int? tempPeopleTo = filterPeopleTo;
    String? tempStateFilter = stateFilter;

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

                  // Datum OD
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
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
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

                  // Datum DO
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
                        firstDate: DateTime(1900),
                        lastDate: DateTime.now(),
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
                        value: "canceled",
                        child: Text("Otkazano"),
                      ),
                      DropdownMenuItem(
                        value: "completed",
                        child: Text("Završeno"),
                      ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        tempStateFilter = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  // Cijena OD
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

                  // Cijena DO
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

                  // Broj osoba OD
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

                  // Broj osoba DO
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
                      // Primijeni
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
                      // Resetiraj
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
                              tempStateFilter = "completed";

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
                              stateFilter = "completed";

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
                  'Historija rezervacija',
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
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),

          // LISTA
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : reservations.isEmpty
                ? const Center(
                    child: Text(
                      "Nema rezervacija",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
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
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SpaceUnitDetailsScreen(
                                spaceUnitId: su.spaceUnitId,
                                openReviewsTab: true,
                                highlightedReservationId:
                                    reservation.reservationId,
                              ),
                            ),
                          );

                          fetchReservations(reset: true);
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // IMAGE full width
                              su.spaceUnitImages.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: const BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      child: Image.network(
                                        "${BaseProvider.baseUrl}${su.spaceUnitImages.first.imagePath}",
                                        width: double.infinity,
                                        height: 180,
                                        fit: BoxFit.cover,
                                        errorBuilder: (c, o, s) =>
                                            const Icon(Icons.broken_image),
                                      ),
                                    )
                                  : Container(
                                      height: 180,
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.image, size: 40),
                                    ),

                              // INFO
                              Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      su.name,
                                      style: const TextStyle(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "Od ${formatDate(reservation.startDate.toLocal())} "
                                      "- ${formatDate(reservation.endDate.toLocal())}",
                                      style: const TextStyle(fontSize: 15),
                                    ),

                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        buildReservationStatus(
                                          reservation.stateMachine,
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "•",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "Osoba: ${reservation.peopleCount}",
                                          style: const TextStyle(fontSize: 15),
                                        ),
                                        const SizedBox(width: 10),
                                        const Text(
                                          "•",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Text(
                                          "${reservation.totalPrice.toStringAsFixed(2)} KM",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 15),

                                    // DUGMAD
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: FutureBuilder<bool>(
                                        future: context
                                            .read<ReservationProvider>()
                                            .hasReviewed(
                                              reservation.reservationId,
                                            ),
                                        builder: (context, snapshot) {
                                          if (!snapshot.hasData) {
                                            return const SizedBox.shrink();
                                          }

                                          final hasReviewed = snapshot.data!;

                                          if (reservation.stateMachine !=
                                              "completed") {
                                            return const SizedBox.shrink();
                                          }

                                          if (hasReviewed) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                top: 10,
                                              ),
                                              child: Container(
                                                width: double.infinity,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 12,
                                                      vertical: 10,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.blueGrey
                                                      .withOpacity(0.08),
                                                  borderRadius:
                                                      BorderRadius.circular(6),
                                                ),
                                                child: Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.info_outline,
                                                      size: 20,
                                                      color: Colors.blueGrey,
                                                    ),
                                                    SizedBox(width: 6),
                                                    Expanded(
                                                      child: Text(
                                                        "Već ste ostavili recenziju",
                                                        style: TextStyle(
                                                          fontSize: 13,
                                                          color: Colors.black87,
                                                          height: 1.35,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          }

                                          // Ako nije recenzirano, prikaži dugme "Ocijeni"
                                          return Row(
                                            children: [
                                              // Dummy dugme (nevidljivo, samo da popuni prostor)
                                              Expanded(
                                                child: SizedBox(height: 44),
                                              ),
                                              const SizedBox(width: 10),

                                              // Pravo dugme Ocijeni
                                              Expanded(
                                                child: ElevatedButton(
                                                  onPressed: () async {
                                                    final result = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (_) =>
                                                            ReviewFormScreen(
                                                              spaceUnitId:
                                                                  reservation
                                                                      .spaceUnit!
                                                                      .spaceUnitId,
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
                                                            "Recenzija je uspješno spremljena",
                                                        backgroundColor:
                                                            Colors.green,
                                                      );

                                                      setState(() {});
                                                    }
                                                  },
                                                  style: ElevatedButton.styleFrom(
                                                    minimumSize: const Size(
                                                      0,
                                                      44,
                                                    ),
                                                    backgroundColor:
                                                        Colors.blue,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                  ),
                                                  child: const Text(
                                                    "Ocijeni",
                                                    style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
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
          ),
        ],
      ),
    );
  }
}

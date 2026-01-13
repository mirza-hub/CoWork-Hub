import 'dart:async';

import 'package:coworkhub_mobile/providers/auth_provider.dart';
import 'package:coworkhub_mobile/providers/base_provider.dart';
import 'package:coworkhub_mobile/providers/reservation_provider.dart';
import 'package:coworkhub_mobile/screens/login_screen.dart';
import 'package:coworkhub_mobile/screens/payment_method_screen.dart';
import 'package:coworkhub_mobile/screens/space_unit_details_screen.dart';
import 'package:coworkhub_mobile/screens/space_unit_map_screen.dart';
import 'package:coworkhub_mobile/utils/flushbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../providers/space_unit_provider.dart';
import '../../models/space_unit.dart';
import 'package:google_fonts/google_fonts.dart';

class SpaceUnitScreen extends StatefulWidget {
  final int workspaceTypeId;
  final int cityId;
  final DateTimeRange dateRange;
  final int peopleCount;
  final String cityName;
  final String workspaceTypeName;

  const SpaceUnitScreen({
    super.key,
    required this.workspaceTypeId,
    required this.cityId,
    required this.cityName,
    required this.workspaceTypeName,
    required this.dateRange,
    required this.peopleCount,
  });

  @override
  State<SpaceUnitScreen> createState() => _SpaceUnitScreenState();
}

class _SpaceUnitScreenState extends State<SpaceUnitScreen> {
  List<SpaceUnit> units = [];
  bool loading = false;
  bool hasMore = true;
  String orderBy = "PricePerDay";
  String sortDirection = "ASC";
  String selectedSort = "";
  dynamic filterCapacityFrom;
  dynamic filterCapacityTo;
  dynamic filterPriceFrom;
  dynamic filterPriceTo;
  int page = 1;
  int totalCount = 0;

  final ScrollController _scrollController = ScrollController();

  late String headerText;

  @override
  void initState() {
    super.initState();

    final start = DateFormat('MMM d').format(widget.dateRange.start);
    final end = DateFormat('MMM d').format(widget.dateRange.end);
    headerText =
        "${widget.workspaceTypeName} • $start - $end • ${widget.cityName}";

    fetchUnits();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 300 &&
          !loading &&
          hasMore) {
        fetchUnits();
      }
    });
  }

  Future<void> fetchUnits({bool reset = false}) async {
    if (loading) return;

    if (reset) {
      units.clear();
      page = 1;
      hasMore = true;
      totalCount = 0;
    }

    setState(() => loading = true);

    var provider = context.read<SpaceUnitProvider>();
    var filter = {
      "CityId": widget.cityId,
      "WorkspaceTypeId": widget.workspaceTypeId,
      "From": widget.dateRange.start.toIso8601String(),
      "To": widget.dateRange.end.toIso8601String(),
      "PeopleCount": widget.peopleCount,
      "IncludeWorkingSpace": true,
      "IncludeWorkspaceType": true,
      "IncludeImages": true,
      "OrderBy": orderBy,
      "SortDirection": sortDirection,
      "Page": page,
      "PageSize": 10,
    };

    if (filterCapacityFrom != null) filter["CapacityFrom"] = filterCapacityFrom;
    if (filterCapacityTo != null) filter["CapacityTo"] = filterCapacityTo;
    if (filterPriceFrom != null) filter["PriceFrom"] = filterPriceFrom;
    if (filterPriceTo != null) filter["PriceTo"] = filterPriceTo;

    var result = await provider.get(filter: filter);

    setState(() {
      if (reset) {
        units = result.resultList;
      } else {
        units.addAll(result.resultList);
      }

      totalCount = result.count!;
      page++;
      loading = false;

      hasMore = units.length < totalCount;
    });
  }

  void showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // privremena varijabla koja prati odabrani radio
        String selectedSort = "$orderBy$sortDirection";

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Sortiraj po",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  RadioListTile(
                    title: const Text("Cijena — manja prema većoj"),
                    value: "PricePerDayASC",
                    groupValue: selectedSort,
                    onChanged: (value) {
                      setModalState(() {
                        selectedSort = value!;
                      });
                    },
                  ),

                  RadioListTile(
                    title: const Text("Cijena — veća prema manjoj"),
                    value: "PricePerDayDESC",
                    groupValue: selectedSort,
                    onChanged: (value) {
                      setModalState(() {
                        selectedSort = value!;
                      });
                    },
                  ),

                  RadioListTile(
                    title: const Text("Naziv — A prema Z"),
                    value: "NameASC",
                    groupValue: selectedSort,
                    onChanged: (value) {
                      setModalState(() {
                        selectedSort = value!;
                      });
                    },
                  ),

                  RadioListTile(
                    title: const Text("Naziv — Z prema A"),
                    value: "NameDESC",
                    groupValue: selectedSort,
                    onChanged: (value) {
                      setModalState(() {
                        selectedSort = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // primijeni izabrani sort
                            if (selectedSort == "PricePerDayASC") {
                              orderBy = "PricePerDay";
                              sortDirection = "ASC";
                            } else if (selectedSort == "PricePerDayDESC") {
                              orderBy = "PricePerDay";
                              sortDirection = "DESC";
                            } else if (selectedSort == "NameASC") {
                              orderBy = "Name";
                              sortDirection = "ASC";
                            } else if (selectedSort == "NameDESC") {
                              orderBy = "Name";
                              sortDirection = "DESC";
                            }

                            units.clear();
                            page = 1;
                            hasMore = true;

                            Navigator.pop(context);
                            fetchUnits();
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

  void _handleReserve(BuildContext context, SpaceUnit su) {
    if (AuthProvider.isSignedIn != true || AuthProvider.userId == null) {
      _showLoginRequiredDialog(context);
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Potvrda rezervacije"),
        content: Text(
          "Da li želite rezervisati prostor \"${su.name}\" "
          "za odabrani period?",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createReservationAndProceed(context, su);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              "Da",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Ne"),
          ),
        ],
      ),
    );
  }

  Future<void> _createReservationAndProceed(
    BuildContext context,
    SpaceUnit su,
  ) async {
    try {
      final reservationProvider = context.read<ReservationProvider>();

      final reservation = await reservationProvider.insert({
        "spaceUnitId": su.spaceUnitId,
        "startDate": widget.dateRange.start.toIso8601String(),
        "endDate": widget.dateRange.end.toIso8601String(),
        "peopleCount": widget.peopleCount,
      });

      // Ovdje push-ujemo PaymentMethodScreen i čekamo rezultat
      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentMethodScreen(
            spaceUnit: su,
            dateRange: widget.dateRange,
            peopleCount: widget.peopleCount,
            reservationId: reservation.reservationId,
          ),
        ),
      );

      if (result == true) {
        showTopFlushBar(
          context: context,
          message: "Rezervacija je uspješno izvršena!",
          backgroundColor: Colors.green,
        );

        fetchUnits(reset: true);
      } else if (result == false) {
        showTopFlushBar(
          context: context,
          message: "Rezervacija nije bila uspješna.",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      showTopFlushBar(
        context: context,
        message: "Greška pri rezervaciji: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Potrebna prijava"),
        content: const Text(
          "Morate biti prijavljeni da biste izvršili rezervaciju.",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text(
              "Prijavite se",
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Odustani"),
          ),
        ],
      ),
    );
  }

  void showFilterOptions() {
    // privremene varijable filtera
    int? tempCapacityFrom = filterCapacityFrom;
    int? tempCapacityTo = filterCapacityTo;
    double? tempPriceFrom = filterPriceFrom;
    double? tempPriceTo = filterPriceTo;

    // Controllers inicijaliziraj samo jednom
    final capacityFromController = TextEditingController(
      text: tempCapacityFrom?.toString() ?? "",
    );
    final capacityToController = TextEditingController(
      text: tempCapacityTo?.toString() ?? "",
    );
    final priceFromController = TextEditingController(
      text: tempPriceFrom?.toString() ?? "",
    );
    final priceToController = TextEditingController(
      text: tempPriceTo?.toString() ?? "",
    );

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Filtriraj",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  // Kapacitet od
                  TextField(
                    controller: capacityFromController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      labelText: "Kapacitet od",
                      prefixIcon: Icon(Icons.people_outlined),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      tempCapacityFrom = int.tryParse(val);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Kapacitet do
                  TextField(
                    controller: capacityToController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    decoration: const InputDecoration(
                      labelText: "Kapacitet do",
                      prefixIcon: Icon(Icons.people_outlined),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      tempCapacityTo = int.tryParse(val);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Cijena od
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
                    onChanged: (val) {
                      tempPriceFrom = double.tryParse(val);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Cijena do
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
                    onChanged: (val) {
                      tempPriceTo = double.tryParse(val);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Dugmad Primijeni + Resetiraj
                  Row(
                    children: [
                      // Primijeni
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              filterCapacityFrom = tempCapacityFrom;
                              filterCapacityTo = tempCapacityTo;
                              filterPriceFrom = tempPriceFrom;
                              filterPriceTo = tempPriceTo;

                              units.clear();
                              page = 1;
                              hasMore = true;
                            });

                            Navigator.pop(context);
                            fetchUnits();
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
                            setState(() {
                              // resetuj filter varijable
                              filterCapacityFrom = null;
                              filterCapacityTo = null;
                              filterPriceFrom = null;
                              filterPriceTo = null;

                              // reset privremenih varijabli u sheet-u
                              tempCapacityFrom = null;
                              tempCapacityTo = null;
                              tempPriceFrom = null;
                              tempPriceTo = null;

                              // očisti TextField kontrole
                              capacityFromController.text = "";
                              capacityToController.text = "";
                              priceFromController.text = "";
                              priceToController.text = "";

                              // resetuj listu i paginaciju
                              units.clear();
                              page = 1;
                              hasMore = true;
                            });

                            // automatski primijeni i zatvori sheet
                            Navigator.pop(context);
                            fetchUnits();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 5,
                  offset: Offset(0, 1.5),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 40, 13, 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'CoWorkHub.com',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.montserrat(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.blueAccent,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 20),

                // BACK + INPUT
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.arrow_back, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Container(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Color.fromARGB(255, 250, 184, 61),
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        alignment: Alignment.centerLeft,
                        child: Text(
                          headerText,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 15,
                            fontFamily: 'RobotoMono',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // SORT / FILTER / MAP
                Row(
                  children: [
                    Expanded(
                      child: Material(
                        color: Colors.white,
                        child: InkWell(
                          onTap: () => showSortOptions(),
                          splashColor: Colors.grey.shade300,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.sort, size: 20),
                                SizedBox(width: 6),
                                Text("Sortiraj"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: Colors.white,
                        child: InkWell(
                          onTap: () => showFilterOptions(),
                          splashColor: Colors.grey.shade300,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.filter_list, size: 20),
                                SizedBox(width: 6),
                                Text("Filtriraj"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Material(
                        color: Colors.white,
                        child: InkWell(
                          onTap: () {
                            if (units.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      SpaceUnitMapScreen(units: units),
                                ),
                              );
                            }
                          },
                          splashColor: Colors.grey.shade300,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.map_outlined, size: 20),
                                SizedBox(width: 6),
                                Text("Karta"),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (!loading && units.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                "Prikazano ${units.length} od $totalCount rezultata",
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          // LISTA
          Expanded(
            child: loading && units.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : units.isEmpty
                ? const Center(
                    child: Text(
                      "Nema slobodnih jedinica",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: units.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == units.length) {
                        return loading
                            ? const Padding(
                                padding: EdgeInsets.all(20),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            : const SizedBox.shrink();
                      }

                      final su = units[index];

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SpaceUnitDetailsScreen(
                                spaceUnitId: su.spaceUnitId,
                                dateRange: widget.dateRange,
                                peopleCount: widget.peopleCount,
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
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 5,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              // IMAGE
                              Container(
                                width: 110,
                                height: 240,
                                child: su.spaceUnitImages.isNotEmpty
                                    ? ClipRRect(
                                        borderRadius:
                                            const BorderRadius.horizontal(
                                              left: Radius.circular(12),
                                            ),
                                        child: Image.network(
                                          "${BaseProvider.baseUrl}${su.spaceUnitImages.first.imagePath}",
                                          fit: BoxFit.cover,
                                          errorBuilder: (c, o, s) =>
                                              const Icon(Icons.broken_image),
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

                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "${widget.cityName} • ${widget.workspaceTypeName}",
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.people,
                                            size: 16,
                                            color: Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Kapacitet: ${su.capacity}",
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 4),
                                      Text(
                                        su.description ?? " nema opisa.",
                                        style: const TextStyle(fontSize: 13),
                                      ),

                                      const SizedBox(height: 8),
                                      Text(
                                        "${su.pricePerDay.toStringAsFixed(2)} KM / dan",
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueAccent,
                                        ),
                                      ),

                                      const SizedBox(height: 10),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          children: [
                                            // PRVA polovina prazna
                                            const Expanded(child: SizedBox()),

                                            const SizedBox(width: 10),

                                            // DRUGA polovina dugme "Rezerviši"
                                            Expanded(
                                              child: ElevatedButton(
                                                onPressed: () {
                                                  _handleReserve(context, su);
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 11,
                                                      ),
                                                  minimumSize: const Size(
                                                    0,
                                                    40,
                                                  ),
                                                  backgroundColor: Colors.blue,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                ),
                                                child: const Text(
                                                  "Rezerviši",
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

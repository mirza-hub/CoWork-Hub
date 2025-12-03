import 'package:coworkhub_mobile/providers/base_provider.dart';
import 'package:coworkhub_mobile/screens/space_unit_map_screen.dart';
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
  int page = 1;
  String orderBy = "PricePerDay";
  String sortDirection = "ASC";
  String selectedSort = "";
  dynamic filterCapacityFrom;
  dynamic filterCapacityTo;
  dynamic filterPriceFrom;
  dynamic filterPriceTo;

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

  Future<void> fetchUnits() async {
    if (loading || !hasMore) return;

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

    if (result.resultList.isEmpty) {
      hasMore = false;
    } else {
      units.addAll(result.resultList);
      page++;
    }

    setState(() => loading = false);
  }

  void showSortOptions() {
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
                    "Sortiraj po",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 20),

                  // Cijena uzlazno
                  RadioListTile(
                    title: const Text("Cijena — manja prema većoj"),
                    value: "price_asc",
                    groupValue: "$orderBy$sortDirection",
                    onChanged: (value) {
                      setModalState(() {
                        orderBy = "PricePerDay";
                        sortDirection = "ASC";
                      });
                    },
                  ),

                  // Cijena silazno
                  RadioListTile(
                    title: const Text("Cijena — veća prema manjoj"),
                    value: "price_desc",
                    groupValue: "$orderBy$sortDirection",
                    onChanged: (value) {
                      setModalState(() {
                        orderBy = "PricePerDay";
                        sortDirection = "DESC";
                      });
                    },
                  ),

                  // Naziv uzlazno
                  RadioListTile(
                    title: const Text("Naziv — A → Z"),
                    value: "name_asc",
                    groupValue: "$orderBy$sortDirection",
                    onChanged: (value) {
                      setModalState(() {
                        orderBy = "Name";
                        sortDirection = "ASC";
                      });
                    },
                  ),

                  // Naziv silazno
                  RadioListTile(
                    title: const Text("Naziv — Z → A"),
                    value: "name_desc",
                    groupValue: "$orderBy$sortDirection",
                    onChanged: (value) {
                      setModalState(() {
                        orderBy = "Name";
                        sortDirection = "DESC";
                      });
                    },
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: () {
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  void showFilterOptions() {
    // koristi trenutne vrijednosti filtera kao inicijalne
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration(
                      labelText: "Kapacitet od",
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration(
                      labelText: "Kapacitet do",
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration(
                      labelText: "Cijena od (KM)",
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textAlign: TextAlign.left,
                    decoration: const InputDecoration(
                      labelText: "Cijena do (KM)",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (val) {
                      tempPriceTo = double.tryParse(val);
                    },
                  ),
                  const SizedBox(height: 20),

                  ElevatedButton(
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
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 5),
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

          // LISTA
          Expanded(
            child: loading && units.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : units.isEmpty
                ? const Center(
                    child: Text(
                      "Nema podataka",
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
                    itemCount: units.length + 1,
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

                      return Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
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
                              width: 150,
                              height: 180,
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
                                  : const Icon(Icons.image, size: 40),
                            ),

                            // INFO
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          style: const TextStyle(fontSize: 13),
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
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[300],
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              "Detalji",
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          ElevatedButton(
                                            onPressed: () {},
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.blue,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
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
                                        ],
                                      ),
                                    ),
                                  ],
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/space_unit.dart';
import '../../providers/space_unit_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../screens/login_screen.dart';
import '../../screens/payment_method_screen.dart';
import '../../utils/flushbar_helper.dart';

class SpaceUnitDetailsScreen extends StatelessWidget {
  final int spaceUnitId;

  // OPTIONAL – ako dolaziš sa search screena
  final DateTimeRange? dateRange;
  final int? peopleCount;

  const SpaceUnitDetailsScreen({
    super.key,
    required this.spaceUnitId,
    this.dateRange,
    this.peopleCount,
  });

  bool get canReserve => dateRange != null && peopleCount != null;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            "Detalji",
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: "Detalji"),
              Tab(text: "Slike"),
              Tab(text: "Recenzije"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SpaceUnitDetailsTab(
              spaceUnitId: spaceUnitId,
              dateRange: dateRange,
              peopleCount: peopleCount,
              canReserve: canReserve,
            ),
            const Center(child: Text("Slike – uskoro")),
            const Center(child: Text("Recenzije – uskoro")),
          ],
        ),
      ),
    );
  }
}

class SpaceUnitDetailsTab extends StatefulWidget {
  final int spaceUnitId;
  final DateTimeRange? dateRange;
  final int? peopleCount;
  final bool canReserve;

  const SpaceUnitDetailsTab({
    super.key,
    required this.spaceUnitId,
    this.dateRange,
    this.peopleCount,
    required this.canReserve,
  });

  @override
  State<SpaceUnitDetailsTab> createState() => _SpaceUnitDetailsTabState();
}

class _SpaceUnitDetailsTabState extends State<SpaceUnitDetailsTab> {
  late Future<SpaceUnit?> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetchSpaceUnit();
  }

  Future<SpaceUnit?> _fetchSpaceUnit() async {
    final provider = context.read<SpaceUnitProvider>();

    final result = await provider.get(
      filter: {
        "SpaceUnitId": widget.spaceUnitId,
        "IncludeWorkingSpace": true,
        "IncludeWorkspaceType": true,
        "IncludeResources": true,
      },
    );

    if (result.resultList.isEmpty) return null;
    return result.resultList.first;
  }

  // ================= REZERVACIJA =================

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
          "Da li želite rezervisati prostor \"${su.name}\" za odabrani period?",
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _createReservationAndProceed(context, su);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
            child: const Text("Da", style: TextStyle(color: Colors.white)),
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
        "startDate": widget.dateRange!.start.toIso8601String(),
        "endDate": widget.dateRange!.end.toIso8601String(),
        "peopleCount": widget.peopleCount!,
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentMethodScreen(
            spaceUnit: su,
            dateRange: widget.dateRange!,
            peopleCount: widget.peopleCount!,
            reservationId: reservation.reservationId,
          ),
        ),
      );
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
        title: const Text("Prijava potrebna"),
        content: const Text(
          "Morate biti prijavljeni da biste izvršili rezervaciju.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Odustani"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text("Prijavite se"),
          ),
        ],
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SpaceUnit?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text("Nema podataka"));
        }

        final su = snapshot.data!;

        final resourcesText = su.spaceUnitResources.isNotEmpty
            ? su.spaceUnitResources
                  .map((e) => e.resources.resourceName)
                  .whereType<String>()
                  .join(", ")
            : "Nema resursa";

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _readOnlyField("Naziv", su.name),
              _readOnlyField("Opis", su.description, maxLines: 3),
              _readOnlyField("Kapacitet", su.capacity.toString()),
              _readOnlyField("Tip prostora", su.workspaceType?.typeName ?? "-"),
              _readOnlyField(
                "Cijena po danu",
                "${su.pricePerDay.toStringAsFixed(2)} KM",
              ),
              _readOnlyField("Radni prostor", su.workingSpace?.name ?? "-"),
              _readOnlyField("Grad", su.workingSpace?.city?.cityName ?? "-"),
              _readOnlyField(
                "Adresa",
                su.workingSpace?.address ?? "-",
                maxLines: 2,
              ),
              _readOnlyField("Resursi", resourcesText, maxLines: 3),

              const SizedBox(height: 20),

              if (widget.canReserve)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _handleReserve(context, su),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 11,
                      ),
                      minimumSize: Size(0, 40), // visina dugmeta
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Rezerviši",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _readOnlyField(String label, String value, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: TextEditingController(text: value),
        enabled: false,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          disabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
        style: const TextStyle(color: Colors.black),
      ),
    );
  }
}

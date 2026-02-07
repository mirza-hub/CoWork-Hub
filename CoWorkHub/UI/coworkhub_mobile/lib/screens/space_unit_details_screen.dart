import 'dart:async';
import 'dart:convert';

import 'package:coworkhub_mobile/models/day_availability.dart';
import 'package:coworkhub_mobile/models/review.dart';
import 'package:coworkhub_mobile/providers/base_provider.dart';
import 'package:coworkhub_mobile/providers/review_provider.dart';
import 'package:coworkhub_mobile/providers/space_unit_image_provider.dart';
import 'package:coworkhub_mobile/providers/working_space_image_provider.dart';
import 'package:coworkhub_mobile/screens/review_form_screen.dart';
import 'package:coworkhub_mobile/screens/space_unit_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../models/space_unit.dart';
import '../../models/user.dart';
import '../../providers/space_unit_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/login_screen.dart';
import '../../screens/payment_method_screen.dart';
import '../../utils/flushbar_helper.dart';

class SpaceUnitDetailsScreen extends StatefulWidget {
  final int spaceUnitId;
  final SpaceUnit? spaceUnit;
  final DateTimeRange? dateRange;
  final int? peopleCount;
  final bool? showReservationControls;
  final bool openReviewsTab;
  final bool showLeaveReviewButton;
  final int? highlightedReservationId;

  const SpaceUnitDetailsScreen({
    super.key,
    required this.spaceUnitId,
    this.spaceUnit,
    this.dateRange,
    this.peopleCount,
    this.showReservationControls,
    this.openReviewsTab = false,
    this.showLeaveReviewButton = false,
    this.highlightedReservationId,
  });

  bool get canReserve =>
      showReservationControls ?? (dateRange != null && peopleCount != null);

  @override
  State<SpaceUnitDetailsScreen> createState() => _SpaceUnitDetailsScreenState();
}

class _SpaceUnitDetailsScreenState extends State<SpaceUnitDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.openReviewsTab ? 2 : 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Detalji",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: const [
            Tab(text: "Detalji"),
            Tab(text: "Slike"),
            Tab(text: "Recenzije"),
          ],
        ),
      ),

      body: TabBarView(
        controller: _tabController,
        children: [
          SpaceUnitDetailsTab(
            spaceUnitId: widget.spaceUnitId,
            spaceUnit: widget.spaceUnit,
            dateRange: widget.dateRange,
            peopleCount: widget.peopleCount,
            canReserve: widget.canReserve,
          ),
          SpaceUnitImagesTab(spaceUnitId: widget.spaceUnitId),
          ReviewsTab(
            spaceUnitId: widget.spaceUnitId,
            showLeaveReviewButton: widget.showLeaveReviewButton,
            highlightedReservationId: widget.highlightedReservationId,
          ),
        ],
      ),
    );
  }
}

class SpaceUnitDetailsTab extends StatefulWidget {
  final int spaceUnitId;
  final SpaceUnit? spaceUnit;
  final DateTimeRange? dateRange;
  final int? peopleCount;
  final bool canReserve;

  const SpaceUnitDetailsTab({
    super.key,
    required this.spaceUnitId,
    this.spaceUnit,
    this.dateRange,
    this.peopleCount,
    required this.canReserve,
  });

  @override
  State<SpaceUnitDetailsTab> createState() => _SpaceUnitDetailsTabState();
}

class _SpaceUnitDetailsTabState extends State<SpaceUnitDetailsTab> {
  late Future<SpaceUnit?> _future;
  DateTimeRange? _selectedDateRange;
  int _peopleCount = 1;
  List<DayAvailability> _dayAvailability = [];
  DateTime _focusedDay = DateTime.now();
  Timer? _peopleDebounce;

  late TextEditingController _peopleController;
  final dateFormat = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();
    _future = _fetchSpaceUnit();

    _selectedDateRange = widget.dateRange;
    _peopleCount = widget.peopleCount ?? 1;
    _peopleController = TextEditingController(text: _peopleCount.toString());
    _focusedDay = widget.dateRange?.start ?? DateTime.now();
    if (widget.canReserve) {
      _loadAvailabilityForMonth(_focusedDay);
    }
  }

  Future<SpaceUnit?> _fetchSpaceUnit() async {
    try {
      final provider = context.read<SpaceUnitProvider>();

      final result = await provider.get(
        filter: {
          "SpaceUnitId": widget.spaceUnitId,
          "IncludeWorkingSpace": true,
          "IncludeWorkspaceType": true,
          "IncludeResources": true,
          "IncludeAll": true,
        },
      );

      if (result.resultList.isNotEmpty) {
        return result.resultList.first;
      }
    } catch (_) {}

    return widget.spaceUnit;
  }

  Future<void> _loadAvailabilityForMonth(DateTime focusedDay) async {
    final provider = context.read<SpaceUnitProvider>();

    final firstDay = DateTime(focusedDay.year, focusedDay.month, 1);
    final lastDay = DateTime(focusedDay.year, focusedDay.month + 1, 0);

    _dayAvailability = await provider.getAvailability(
      spaceUnitId: widget.spaceUnitId,
      from: firstDay,
      to: lastDay,
      peopleCount: _peopleCount,
    );

    setState(() {});
  }

  void _onPeopleCountChanged(int value) {
    _peopleDebounce?.cancel();

    _peopleDebounce = Timer(const Duration(milliseconds: 400), () {
      _reloadAvailability();
    });
  }

  Future<void> _reloadAvailability() async {
    final provider = context.read<SpaceUnitProvider>();

    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    _dayAvailability = await provider.getAvailability(
      spaceUnitId: widget.spaceUnitId,
      from: firstDayOfMonth,
      to: lastDayOfMonth,
      peopleCount: _peopleCount,
    );

    setState(() {});
  }

  Widget _buildDayCell(DateTime day, Color color, {bool disabled = false}) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          decoration: disabled
              ? TextDecoration.lineThrough
              : TextDecoration.none,
        ),
      ),
    );
  }

  bool _isDayAvailable(DateTime day) {
    final match = _dayAvailability.firstWhere(
      (d) => isSameDay(d.date, day),
      orElse: () => DayAvailability(
        date: day,
        isAvailable: false,
        capacity: 0,
        reserved: 0,
        free: 0,
      ),
    );

    return match.isAvailable;
  }

  // Rezervacija
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
        "startDate": _selectedDateRange!.start.toIso8601String(),
        "endDate": _selectedDateRange!.end.toIso8601String(),
        "peopleCount": _peopleCount,
      });

      showTopFlushBar(
        context: context,
        message: "Rezervacija je uspješno izvršena",
        backgroundColor: Colors.green,
      );

      await Future.delayed(const Duration(seconds: 3));
      await _refreshData();

      final result = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentMethodScreen(
            spaceUnit: su,
            dateRange: _selectedDateRange!,
            peopleCount: _peopleCount,
            reservationId: reservation.reservationId,
          ),
        ),
      );

      if (result == true) {
        showTopFlushBar(
          context: context,
          message: "Rezervacija je uspješno plaćena",
          backgroundColor: Colors.green,
        );
        await _refreshData();
      } else if (result == false) {
        showTopFlushBar(
          context: context,
          message:
              "Plaćanje nije bilo uspješno, nastavite sa plaćanjem kasnije.",
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      String message = "Greška pri rezervaciji.";

      if (e is http.Response) {
        try {
          final errorJson = jsonDecode(e.body);
          if (errorJson["errors"] != null &&
              errorJson["errors"]["userError"] != null) {
            message = errorJson["errors"]["userError"][0];
          }
        } catch (_) {}
      }
      showTopFlushBar(
        context: context,
        message: message,
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
                MaterialPageRoute(
                  builder: (_) => LoginScreen(
                    returnRoute: MaterialPageRoute(
                      builder: (_) => SpaceUnitDetailsScreen(
                        spaceUnitId: widget.spaceUnitId,
                        dateRange: _selectedDateRange,
                        peopleCount: _peopleCount,
                      ),
                    ),
                  ),
                ),
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

  Future<void> _refreshData() async {
    _future = _fetchSpaceUnit();

    final provider = context.read<SpaceUnitProvider>();
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final lastDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0);

    _dayAvailability = await provider.getAvailability(
      spaceUnitId: widget.spaceUnitId,
      from: firstDayOfMonth,
      to: lastDayOfMonth,
      peopleCount: _peopleCount,
    );

    setState(() {});
  }

  @override
  void dispose() {
    _peopleDebounce?.cancel();
    _peopleController.dispose();
    super.dispose();
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SpaceUnit?>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return const Center(
            child: Text(
              "Nema recenzija",
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
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
              _readOnlyField("Firma", su.workingSpace?.name ?? "-"),
              _readOnlyField("Grad", su.workingSpace?.city?.cityName ?? "-"),
              _readOnlyFieldWithMap(
                "Adresa",
                su.workingSpace?.address ?? "-",
                su,
                maxLines: 2,
              ),
              _readOnlyField("Resursi", resourcesText, maxLines: 3),
              if (widget.canReserve) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Colors.blueGrey,
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          "Rezervacija pokriva cijele dane od početnog do završnog datuma uključujući završni dan",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // DATUM
                TableCalendar(
                  firstDay: DateTime.now(),
                  lastDay: DateTime(2100),
                  focusedDay: _focusedDay,
                  calendarStyle: const CalendarStyle(
                    isTodayHighlighted: false,
                    outsideDaysVisible: false,
                  ),
                  headerStyle: HeaderStyle(formatButtonVisible: false),
                  enabledDayPredicate: (day) {
                    return _isDayAvailable(day);
                  },
                  onPageChanged: (focusedDay) async {
                    _focusedDay = focusedDay;

                    final firstDayOfMonth = DateTime(
                      focusedDay.year,
                      focusedDay.month,
                      1,
                    );
                    final lastDayOfMonth = DateTime(
                      focusedDay.year,
                      focusedDay.month + 1,
                      0,
                    );

                    final provider = context.read<SpaceUnitProvider>();

                    _dayAvailability = await provider.getAvailability(
                      spaceUnitId: widget.spaceUnitId,
                      from: firstDayOfMonth,
                      to: lastDayOfMonth,
                      peopleCount: _peopleCount,
                    );

                    print("Učitano ${_dayAvailability.length} dana");
                    setState(() {});
                  },
                  selectedDayPredicate: (day) {
                    if (_selectedDateRange == null) return false;
                    final start = _selectedDateRange!.start;
                    final end = _selectedDateRange!.end;
                    final isOnOrAfterStart =
                        isSameDay(day, start) || day.isAfter(start);
                    final isOnOrBeforeEnd =
                        isSameDay(day, end) || day.isBefore(end);
                    return isOnOrAfterStart && isOnOrBeforeEnd;
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    if (!_isDayAvailable(selectedDay)) return;

                    setState(() {
                      _focusedDay = focusedDay;

                      if (_selectedDateRange != null &&
                          isSameDay(_selectedDateRange!.start, selectedDay) &&
                          isSameDay(_selectedDateRange!.end, selectedDay)) {
                        _selectedDateRange = null;
                        return;
                      }

                      if (_selectedDateRange == null) {
                        _selectedDateRange = DateTimeRange(
                          start: selectedDay,
                          end: selectedDay,
                        );
                        return;
                      }

                      if (isSameDay(
                        _selectedDateRange!.start,
                        _selectedDateRange!.end,
                      )) {
                        final start = _selectedDateRange!.start;

                        _selectedDateRange = DateTimeRange(
                          start: start.isBefore(selectedDay)
                              ? start
                              : selectedDay,
                          end: start.isBefore(selectedDay)
                              ? selectedDay
                              : start,
                        );
                        return;
                      }

                      _selectedDateRange = DateTimeRange(
                        start: selectedDay,
                        end: selectedDay,
                      );
                    });
                  },

                  calendarBuilders: CalendarBuilders(
                    defaultBuilder: (context, day, _) {
                      final isCurrentMonth =
                          day.year == _focusedDay.year &&
                          day.month == _focusedDay.month;

                      if (!isCurrentMonth) {
                        return SizedBox.shrink();
                      }

                      final availability = _dayAvailability.firstWhere(
                        (d) => isSameDay(d.date, day),
                        orElse: () => DayAvailability(
                          date: day,
                          isAvailable: false,
                          capacity: 0,
                          reserved: 0,
                          free: 0,
                        ),
                      );

                      return _buildDayCell(
                        day,
                        availability.isAvailable ? Colors.green : Colors.red,
                      );
                    },

                    disabledBuilder: (context, day, _) {
                      return _buildDayCell(day, Colors.red, disabled: true);
                    },

                    selectedBuilder: (context, day, _) {
                      return _buildDayCell(day, Colors.orange);
                    },

                    todayBuilder: (context, day, _) {
                      return _buildDayCell(day, Colors.blueAccent);
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // BROJ LJUDI
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _peopleController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Broj ljudi',
                          prefixIcon: Icon(Icons.people_outlined),
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null && parsed >= 1 && parsed <= 10) {
                            setState(() {
                              _peopleCount = parsed;
                              _selectedDateRange = null;
                            });
                            _onPeopleCountChanged(parsed);
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
                            onPressed: _peopleCount < 10
                                ? () {
                                    setState(() {
                                      _peopleCount++;
                                      _peopleController.text = _peopleCount
                                          .toString();
                                      _selectedDateRange = null;
                                    });

                                    _onPeopleCountChanged(_peopleCount);
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
                            onPressed: _peopleCount > 1
                                ? () {
                                    setState(() {
                                      _peopleCount--;
                                      _peopleController.text = _peopleCount
                                          .toString();
                                      _selectedDateRange = null;
                                    });

                                    _onPeopleCountChanged(_peopleCount);
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
                if (_selectedDateRange != null && _peopleCount > 0)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleReserve(context, su),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 11,
                        ),
                        minimumSize: Size(0, 40),
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

  Widget _readOnlyFieldWithMap(
    String label,
    String value,
    SpaceUnit su, {
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
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
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.map, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SpaceUnitMapScreen(units: [su]),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SpaceUnitImagesTab extends StatefulWidget {
  final int spaceUnitId;
  const SpaceUnitImagesTab({super.key, required this.spaceUnitId});

  @override
  State<SpaceUnitImagesTab> createState() => _SpaceUnitImagesTabState();
}

class _SpaceUnitImagesTabState extends State<SpaceUnitImagesTab> {
  bool loading = true;

  List<String> workingSpaceImagePaths = [];
  List<String> spaceUnitImagePaths = [];

  int _loadedCalls = 0;

  @override
  void initState() {
    super.initState();
    _loadWorkingSpaceImages();
    _loadSpaceUnitImages();
  }

  void _markLoaded() {
    _loadedCalls++;
    if (_loadedCalls == 2) {
      setState(() => loading = false);
    }
  }

  Future<void> _loadWorkingSpaceImages() async {
    try {
      final spaceUnitProvider = Provider.of<SpaceUnitProvider>(
        context,
        listen: false,
      );
      final workingSpaceImageProvider = Provider.of<WorkingSpaceImageProvider>(
        context,
        listen: false,
      );

      final suResult = await spaceUnitProvider.get(
        filter: {
          "SpaceUnitId": widget.spaceUnitId,
          "IncludeWorkingSpace": true,
          "RetrieveAll": true,
        },
      );

      if (suResult.resultList.isEmpty) {
        _markLoaded();
        return;
      }

      final workingSpaceId =
          suResult.resultList.first.workingSpace?.workingSpacesId;

      if (workingSpaceId == null) {
        _markLoaded();
        return;
      }

      final wsImages = await workingSpaceImageProvider.get(
        filter: {"WorkingSpaceId": workingSpaceId, "RetrieveAll": true},
      );

      workingSpaceImagePaths = wsImages.resultList
          .where((e) => e.imagePath != null)
          .map((e) => e.imagePath!)
          .toList();
    } catch (e) {
      debugPrint("GREŠKA WORKING SPACE SLIKE: $e");
    } finally {
      _markLoaded();
    }
  }

  Future<void> _loadSpaceUnitImages() async {
    try {
      final spaceUnitImageProvider = Provider.of<SpaceUnitImageProvider>(
        context,
        listen: false,
      );

      final suImages = await spaceUnitImageProvider.get(
        filter: {"SpaceUnitId": widget.spaceUnitId, "RetrieveAll": true},
      );

      spaceUnitImagePaths = suImages.resultList
          .where((e) => e.imagePath != null)
          .map((e) => e.imagePath)
          .toList();
    } catch (e) {
      debugPrint("GREŠKA SPACE UNIT SLIKE: $e");
    } finally {
      _markLoaded();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (workingSpaceImagePaths.isEmpty && spaceUnitImagePaths.isEmpty) {
      return const Center(
        child: Text(
          "Nema slika",
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (workingSpaceImagePaths.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Slike radnog prostora",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            _buildGrid(workingSpaceImagePaths),
          ],
          if (spaceUnitImagePaths.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "Slike prostorne jedinice",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            _buildGrid(spaceUnitImagePaths),
          ],
        ],
      ),
    );
  }

  Widget _buildGrid(List<String> images) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: images.length,
      itemBuilder: (_, index) {
        final imageUrl = "${BaseProvider.baseUrl}${images[index]}";

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) =>
                    ImageViewerScreen(images: images, initialIndex: index),
              ),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              loadingBuilder: (c, child, progress) {
                if (progress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
            ),
          ),
        );
      },
    );
  }
}

class ReviewsTab extends StatefulWidget {
  final int spaceUnitId;
  final bool showLeaveReviewButton;
  final int? highlightReservationId;
  final int? highlightedReservationId;

  const ReviewsTab({
    super.key,
    required this.spaceUnitId,
    required this.showLeaveReviewButton,
    this.highlightReservationId,
    this.highlightedReservationId,
  });

  @override
  State<ReviewsTab> createState() => _ReviewsTabState();
}

class _ReviewsTabState extends State<ReviewsTab> {
  List<Review> reviews = [];
  bool loading = false;
  int totalCount = 0;
  int page = 1;
  bool hasMore = true;
  final int pageSize = 10;

  late ScrollController _scrollController;
  // Cache for fetched users keyed by usersId
  final Map<int, User?> _fetchedUsers = {};
  final Set<int> _loadingUserIds = {};

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _fetchReviews();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !loading &&
        hasMore) {
      page++;
      _fetchReviews();
    }
  }

  Future<void> _fetchReviews({bool reset = false}) async {
    if (loading) return;

    if (reset) {
      reviews.clear();
      page = 1;
      hasMore = true;
    }

    setState(() => loading = true);

    final provider = context.read<ReviewProvider>();
    final filter = {
      "SpaceUnitId": widget.spaceUnitId,
      "IncludeReservation": true,
      "Page": page,
      "PageSize": pageSize,
      "IsDeleted": false,
    };

    try {
      final result = await provider.get(filter: filter);

      setState(() {
        if (reset) {
          reviews = result.resultList;
        } else {
          reviews.addAll(result.resultList);
        }

        totalCount = result.count ?? reviews.length;
        loading = false;

        if (reviews.length >= totalCount) hasMore = false;
      });
    } catch (e) {
      setState(() => loading = false);
      showTopFlushBar(
        context: context,
        message: "Greška pri dohvaćanju recenzija: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  Future<void> _fetchUserIfNeeded(int usersId) async {
    if (_fetchedUsers.containsKey(usersId) || _loadingUserIds.contains(usersId))
      return;

    _loadingUserIds.add(usersId);
    try {
      final provider = context.read<UserProvider>();
      final result = await provider.get(
        filter: {"UsersId": usersId, "IsUserRolesIncluded": false},
      );

      if (result.resultList.isNotEmpty) {
        _fetchedUsers[usersId] = result.resultList.first;
      } else {
        _fetchedUsers[usersId] = null;
      }
    } catch (e) {
      _fetchedUsers[usersId] = null;
    } finally {
      _loadingUserIds.remove(usersId);
      if (mounted) setState(() {});
    }
  }

  Future<void> _deleteReview(int reviewId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text("Potvrda brisanja"),
          content: const Text(
            "Da li ste sigurni da želite obrisati ovu recenziju?",
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

    if (confirmed != true) return;

    try {
      final provider = context.read<ReviewProvider>();
      await provider.delete(reviewId);

      showTopFlushBar(
        context: context,
        message: "Recenzija obrisana",
        backgroundColor: Colors.green,
      );

      setState(() {
        reviews.removeWhere((r) => r.reviewsId == reviewId);
        _fetchReviews(reset: true);
      });
    } catch (e) {
      showTopFlushBar(
        context: context,
        message: "Greška pri brisanju recenzije: $e",
        backgroundColor: Colors.red,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (reviews.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              "Prikazano ${reviews.length} od $totalCount recenzija",
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ),
        Expanded(
          child: reviews.isEmpty
              ? Center(
                  child: loading
                      ? const CircularProgressIndicator()
                      : const Text(
                          "Nema recenzija",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                )
              : ListView.separated(
                  controller: _scrollController,
                  itemCount: reviews.length + (hasMore ? 1 : 0),
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Colors.grey),
                  itemBuilder: (context, index) {
                    if (index == reviews.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }

                    final r = reviews[index];
                    final isHighlighted =
                        widget.highlightedReservationId != null &&
                        r.reservation?.reservationId ==
                            widget.highlightedReservationId;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isHighlighted ? Colors.blue[50] : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: isHighlighted
                            ? Border.all(color: Colors.blue, width: 1.5)
                            : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Builder(
                                builder: (context) {
                                  final usersObj = r.reservation?.users;
                                  final usersId = r.reservation?.usersId;

                                  String? first = usersObj?.firstName;
                                  String? last = usersObj?.lastName;

                                  // If users object missing but usersId exists, try cached fetched user
                                  if ((first == null || first.isEmpty) &&
                                      (last == null || last.isEmpty) &&
                                      usersId != null) {
                                    if (_fetchedUsers.containsKey(usersId)) {
                                      final u = _fetchedUsers[usersId];
                                      first = u?.firstName;
                                      last = u?.lastName;
                                    } else if (!_loadingUserIds.contains(
                                      usersId,
                                    )) {
                                      // trigger fetch
                                      _fetchUserIfNeeded(usersId);
                                    }
                                  }

                                  final hasName =
                                      (first != null && first.isNotEmpty) ||
                                      (last != null && last.isNotEmpty);

                                  if (!hasName) {
                                    // show spinner if loading for this userId, otherwise fallback text
                                    if (usersId != null &&
                                        _loadingUserIds.contains(usersId)) {
                                      return Row(
                                        children: const [
                                          SizedBox(
                                            width: 14,
                                            height: 14,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            "Učitavanje...",
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      );
                                    }

                                    return const Text(
                                      'Nepoznati korisnik',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    );
                                  }

                                  final displayName =
                                      "${first ?? ''} ${last ?? ''}".trim();
                                  return Text(
                                    displayName.isNotEmpty
                                        ? displayName
                                        : 'Nepoznati korisnik',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  );
                                },
                              ),
                              Text(
                                "${r.createdAt.day}.${r.createdAt.month}.${r.createdAt.year}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: List.generate(
                              5,
                              (i) => Icon(
                                i < r.rating ? Icons.star : Icons.star_border,
                                color: Colors.orange,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(r.comment, style: const TextStyle(fontSize: 14)),

                          if (isHighlighted) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => ReviewFormScreen(
                                          spaceUnitId: widget.spaceUnitId,
                                          existingReview: r,
                                        ),
                                      ),
                                    );
                                    if (result == true) {
                                      showTopFlushBar(
                                        context: context,
                                        message:
                                            "Recenzija je uspješno promjenjena",
                                        backgroundColor: Colors.green,
                                      );
                                      _fetchReviews(reset: true);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                  ),
                                  child: const Text(
                                    "Uredi",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () => _deleteReview(r.reviewsId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  child: const Text(
                                    "Obriši",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
        ),
        // OSTAVI RECENZIJU dugme
        if (widget.showLeaveReviewButton &&
            !reviews.any(
              (r) =>
                  r.reservation?.reservationId == widget.highlightReservationId,
            ))
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Ostavi recenziju",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class DisplayImage {
  final String imagePath;
  final bool isFromSpaceUnit;

  DisplayImage({required this.imagePath, required this.isFromSpaceUnit});
}

class ImageViewerScreen extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const ImageViewerScreen({
    super.key,
    required this.images,
    required this.initialIndex,
  });

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _next() {
    if (_currentIndex < widget.images.length - 1) {
      setState(() => _currentIndex++);
    }
  }

  void _prev() {
    if (_currentIndex > 0) {
      setState(() => _currentIndex--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageUrl = "${BaseProvider.baseUrl}${widget.images[_currentIndex]}";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "${_currentIndex + 1} / ${widget.images.length}",
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (c, child, p) {
                if (p == null) return child;
                return const CircularProgressIndicator(color: Colors.white);
              },
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.broken_image, color: Colors.white, size: 50),
            ),
          ),

          Positioned(
            left: 10,
            top: 0,
            bottom: 0,
            child: IconButton(
              iconSize: 40,
              color: Colors.white,
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: _prev,
            ),
          ),

          Positioned(
            right: 10,
            top: 0,
            bottom: 0,
            child: IconButton(
              iconSize: 40,
              color: Colors.white,
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: _next,
            ),
          ),
        ],
      ),
    );
  }
}

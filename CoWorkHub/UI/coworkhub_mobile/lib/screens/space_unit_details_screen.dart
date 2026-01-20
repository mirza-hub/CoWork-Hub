import 'package:coworkhub_mobile/models/review.dart';
import 'package:coworkhub_mobile/providers/base_provider.dart';
import 'package:coworkhub_mobile/providers/review_provider.dart';
import 'package:coworkhub_mobile/providers/space_unit_image_provider.dart';
import 'package:coworkhub_mobile/providers/working_space_image_provider.dart';
import 'package:coworkhub_mobile/screens/review_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/space_unit.dart';
import '../../providers/space_unit_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/reservation_provider.dart';
import '../../screens/login_screen.dart';
import '../../screens/payment_method_screen.dart';
import '../../utils/flushbar_helper.dart';

class SpaceUnitDetailsScreen extends StatefulWidget {
  final int spaceUnitId;
  final SpaceUnit? spaceUnit;
  final DateTimeRange? dateRange;
  final int? peopleCount;
  final bool openReviewsTab;
  final bool showLeaveReviewButton;
  final int? highlightedReservationId;

  const SpaceUnitDetailsScreen({
    super.key,
    required this.spaceUnitId,
    this.spaceUnit,
    this.dateRange,
    this.peopleCount,
    this.openReviewsTab = false,
    this.showLeaveReviewButton = false,
    this.highlightedReservationId,
  });

  bool get canReserve => dateRange != null && peopleCount != null;

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

  // REZERVACIJA
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
                "Slike prostornejedinice",
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
                              Text(
                                "${r.reservation?.users?.firstName} ${r.reservation?.users?.lastName}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
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

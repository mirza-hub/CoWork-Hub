import 'package:coworkhub_desktop/providers/dashboard_provider.dart';
import 'package:coworkhub_desktop/utils/pdf_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  final Function(Widget)? onChangeScreen;

  const DashboardScreen({super.key, this.onChangeScreen});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DashboardProvider()
        ..fetchStats()
        ..fetchRevenueByMonth(),
      child: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          final stats = provider.stats;
          if (stats == null) {
            return const Center(child: Text("No data"));
          }

          return SizedBox.expand(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Spacer(),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final provider = context.read<DashboardProvider>();
                            if (provider.stats != null) {
                              await PdfHelper.saveDashboardPdf(
                                context,
                                provider.stats!,
                                revenueByMonth: provider.revenueByMonth,
                              );
                            }
                          },
                          icon: const Icon(
                            Icons.picture_as_pdf,
                            color: Colors.white,
                          ),
                          label: const Text(
                            "Export PDF",
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // CARDOVI
                    Wrap(
                      spacing: 15,
                      runSpacing: 15,
                      children: [
                        _buildStatCard(
                          "Ukupno rezervacija",
                          stats.totalReservations.toString(),
                        ),
                        _buildStatCard(
                          "Aktivne rezervacije",
                          stats.activeReservations.toString(),
                        ),
                        _buildStatCard(
                          "Otkazane rezervacije",
                          stats.cancelledReservations.toString(),
                        ),
                        _buildStatCard(
                          "Korisnici",
                          stats.totalUsers.toString(),
                        ),
                        _buildStatCard(
                          "Workspace-ovi",
                          stats.totalWorkingSpaces.toString(),
                        ),
                        _buildStatCard(
                          "Prihod",
                          "${stats.totalRevenue.toStringAsFixed(2)} KM",
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // BAR CHART: Rezervacije po gradovima
                    if (stats.reservationsByCity != null &&
                        stats.reservationsByCity!.isNotEmpty) ...[
                      Text(
                        "Rezervacije po gradovima",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 150,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: stats.reservationsByCity!.entries.map((e) {
                            final maxValue = stats.reservationsByCity!.values
                                .reduce((a, b) => a > b ? a : b);
                            final height = e.value / maxValue * 100;
                            return Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(e.value.toString()),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: height.toDouble(),
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    e.key,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // BAR CHART: Rezervacije po workspace tipu
                    if (stats.reservationsByWorkspaceType != null &&
                        stats.reservationsByWorkspaceType!.isNotEmpty) ...[
                      Text(
                        "Rezervacije po tipu workspace-a",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 150,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: stats.reservationsByWorkspaceType!.entries
                              .map((e) {
                                final maxValue = stats
                                    .reservationsByWorkspaceType!
                                    .values
                                    .reduce((a, b) => a > b ? a : b);
                                final height = e.value / maxValue * 100;
                                return Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(e.value.toString()),
                                      const SizedBox(height: 4),
                                      Container(
                                        height: height.toDouble(),
                                        color: Colors.green,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        e.key,
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                );
                              })
                              .toList(),
                        ),
                      ),
                    ],

                    const SizedBox(height: 30),

                    // LINE/ BAR CHART: Prihod po mesecima
                    if (provider.revenueByMonth != null &&
                        provider.revenueByMonth!.isNotEmpty) ...[
                      Text(
                        "Prihod po mjesecima",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 200,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: provider.revenueByMonth!.map((r) {
                            final maxRevenue = provider.revenueByMonth!
                                .map((e) => e.revenue)
                                .reduce((a, b) => a > b ? a : b);
                            final height = r.revenue / maxRevenue * 150;
                            return Container(
                              width: 60,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    "${r.revenue.toStringAsFixed(0)} KM",
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    height: height.toDouble(),
                                    width: 40,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    r.month,
                                    style: const TextStyle(fontSize: 10),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      width: 150, // fiksna širina
      height: 140, // fiksna visina za sve kartice
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF4F5F7),
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center, // centriranje vertikalno
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, color: Colors.black54),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

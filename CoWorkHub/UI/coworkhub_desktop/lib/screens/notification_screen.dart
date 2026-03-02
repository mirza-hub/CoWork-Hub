import 'package:coworkhub_desktop/providers/notification_provider.dart';
import 'package:coworkhub_desktop/providers/auth_provider.dart';
import 'package:coworkhub_desktop/utils/format_date.dart';
import 'package:flutter/material.dart';

import '../models/notification.dart' as model;

class NotificationScreen extends StatefulWidget {
  final void Function(Widget) onChangeScreen;

  const NotificationScreen({super.key, required this.onChangeScreen});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<model.Notification> notifications = [];
  bool loading = false;
  int totalCount = 0;
  int page = 1;
  bool hasMore = true;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    fetchNotifications();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent &&
          !loading &&
          hasMore) {
        page++;
        fetchNotifications();
      }
    });
  }

  Future<void> fetchNotifications({bool reset = false}) async {
    if (loading) return;

    if (reset) {
      notifications.clear();
      page = 1;
      hasMore = true;
    }

    setState(() => loading = true);

    final provider = NotificationProvider();
    final Map<String, dynamic> filter = {
      "UserId": AuthProvider.userId,
      "Page": page,
      "PageSize": 10,
      "OrderBy": "CreatedAt",
      "SortDirection": "desc",
    };

    try {
      final result = await provider.get(filter: filter);
      setState(() {
        if (reset) {
          notifications = result.resultList;
        } else {
          notifications.addAll(result.resultList);
        }
        totalCount = result.count ?? 0;
        loading = false;
        if (notifications.length >= totalCount) {
          hasMore = false;
        }
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: const [
              Center(
                child: Text(
                  "Notifikacije",
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (!loading && notifications.isNotEmpty) ...[
            ElevatedButton(
              onPressed: () async {
                try {
                  await NotificationProvider().markAllAsRead();
                  fetchNotifications(reset: true);
                } catch (e) {
                  // ignore errors
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                "Označi sve pročitano",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                "Prikazano ${notifications.length} od $totalCount notifikacija",
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
          ],

          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : notifications.isEmpty
                ? const Center(
                    child: Text(
                      "Nema notifikacija",
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                : ListView.builder(
                    key: const PageStorageKey('desktopNotificationsList'),
                    controller: _scrollController,
                    padding: const EdgeInsets.only(top: 10),
                    itemCount: notifications.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == notifications.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final n = notifications[index];
                      return InkWell(
                        onTap: () async {
                          bool refreshed = false;
                          if (!n.isRead) {
                            try {
                              await NotificationProvider().markAsRead(
                                n.notificationId,
                              );
                              refreshed = true;
                            } catch (_) {}
                          }

                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                titlePadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                title: Row(
                                  children: [
                                    const Expanded(child: Text('Poruka')),
                                    IconButton(
                                      icon: const Icon(Icons.close),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ],
                                ),
                                content: Text(
                                  n.message,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              );
                            },
                          ).then((_) {
                            if (refreshed) fetchNotifications(reset: true);
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                n.message,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: n.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formatDate(n.createdAt.toLocal()),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
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

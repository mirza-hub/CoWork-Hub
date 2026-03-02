import 'package:coworkhub_mobile/providers/notification_provider.dart';
import 'package:coworkhub_mobile/providers/auth_provider.dart';
import 'package:coworkhub_mobile/utils/format_date.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/notification.dart' as model;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<model.Notification> notifications = [];
  bool loading = false;
  int totalCount = 0;
  DateTime? filterDateFrom;
  DateTime? filterDateTo;
  String isReadFilter = "all";
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

    final provider = context.read<NotificationProvider>();
    final Map<String, dynamic> filter = {
      "UserId": AuthProvider.userId,
      "Page": page,
      "PageSize": 10,
      "OrderBy": "CreatedAt",
      "SortDirection": "desc",
    };

    if (isReadFilter != "all") {
      filter["IsRead"] = isReadFilter == "read";
    }
    if (filterDateFrom != null) {
      filter["DateFrom"] = filterDateFrom!.toIso8601String();
    }
    if (filterDateTo != null) {
      filter["DateTo"] = filterDateTo!.toIso8601String();
    }

    try {
      final result = await provider.get(filter: filter);
      setState(() {
        if (reset) {
          notifications = result.resultList;
        } else {
          notifications.addAll(result.resultList);
        }
        totalCount = result.count!;
        loading = false;
        if (notifications.length >= totalCount) {
          hasMore = false;
        }
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  String _truncate(String text, [int len = 30]) {
    if (text.length <= len) return text;
    return text.substring(0, len) + '...';
  }

  void showFilterOptions() {
    String tempIsRead = isReadFilter;
    DateTime? tempDateFrom = filterDateFrom;
    DateTime? tempDateTo = filterDateTo;

    final dateFromController = TextEditingController(
      text: tempDateFrom != null ? formatDate(tempDateFrom) : '',
    );
    final dateToController = TextEditingController(
      text: tempDateTo != null ? formatDate(tempDateTo) : '',
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

                  DropdownButtonFormField<String>(
                    value: tempIsRead,
                    decoration: const InputDecoration(
                      labelText: "Status čitanja",
                      prefixIcon: Icon(Icons.mark_email_read_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(value: "all", child: Text("Sve")),
                      DropdownMenuItem(value: "read", child: Text("Pročitane")),
                      DropdownMenuItem(
                        value: "unread",
                        child: Text("Nepročitane"),
                      ),
                    ],
                    onChanged: (v) {
                      setModalState(() {
                        tempIsRead = v!;
                      });
                    },
                  ),
                  const SizedBox(height: 10),

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
                        firstDate: DateTime(2000),
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
                        firstDate: DateTime(2000),
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

                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            setState(() {
                              isReadFilter = tempIsRead;
                              filterDateFrom = tempDateFrom;
                              filterDateTo = tempDateTo;
                            });
                            fetchNotifications(reset: true);
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
                            setModalState(() {
                              tempIsRead = "all";
                              tempDateFrom = null;
                              tempDateTo = null;
                              dateFromController.clear();
                              dateToController.clear();
                            });
                            Navigator.pop(context);
                            setState(() {
                              isReadFilter = "all";
                              filterDateFrom = null;
                              filterDateTo = null;
                            });
                            fetchNotifications(reset: true);
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // header
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
                  'Notifikacije',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
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

          if (!loading && notifications.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Text(
                "Prikazano ${notifications.length} od $totalCount notifikacija",
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await context.read<NotificationProvider>().markAllAsRead();
                  fetchNotifications(reset: true);
                } catch (e) {
                  // optionally show error
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
                    key: const PageStorageKey('notificationsList'),
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
                              await context
                                  .read<NotificationProvider>()
                                  .markAsRead(n.notificationId);
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

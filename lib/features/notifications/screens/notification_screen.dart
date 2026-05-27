// ======================================================
// FILE:
// lib/features/notifications/screens/notification_screen.dart
// ======================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/notification_provider.dart';

import '../widgets/notification_tile.dart';

class NotificationScreen
    extends StatefulWidget {

  const NotificationScreen({
    super.key,
  });

  @override
  State<NotificationScreen>
      createState() =>
          _NotificationScreenState();

}

class _NotificationScreenState
    extends State<NotificationScreen> {

  @override
  void initState() {

    super.initState();

    Future.microtask(() {

      Provider.of<
          NotificationProvider>(
        context,
        listen: false,
      ).fetchNotifications();

    });

  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final provider =
        Provider.of<
            NotificationProvider>(
      context,
    );

    return Scaffold(

      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(

        backgroundColor:
            Colors.transparent,

        elevation: 0,

        title: const Text(
          'Notifications',
        ),

        actions: [

          if (provider
                  .notifications
                  .isNotEmpty)

            TextButton(

              onPressed:
                  provider.markAllAsRead,

              child: const Text(
                'Mark all read',
              ),

            ),

        ],

      ),

      body:
          provider.isLoading

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : provider
                      .notifications
                      .isEmpty

                  ? _buildEmptyState()

                  : RefreshIndicator(

                      onRefresh:
                          provider
                              .fetchNotifications,

                      child:
                          ListView.builder(

                        padding:
                            const EdgeInsets
                                .all(18),

                        itemCount:
                            provider
                                .notifications
                                .length,

                        itemBuilder:
                            (
                              context,
                              index,
                            ) {

                          final notification =
                              provider
                                      .notifications[
                                  index];

                          return NotificationTile(

                            notification:
                                notification,

                            onTap: () {

                              provider
                                  .markAsRead(
                                notification.id,
                              );

                            },

                            onDelete: () {

                              provider
                                  .deleteNotification(
                                notification.id,
                              );

                            },

                          );

                        },

                      ),

                    ),

    );

  }

  // ======================================================
  // EMPTY STATE
  // ======================================================

  Widget _buildEmptyState() {

    return Center(

      child: Padding(

        padding:
            const EdgeInsets.all(
          24,
        ),

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            Icon(

              Icons.notifications_off,

              size: 90,

              color:
                  Colors.grey.shade400,

            ),

            const SizedBox(
              height: 20,
            ),

            const Text(

              'No Notifications',

              style: TextStyle(

                fontSize: 24,

                fontWeight:
                    FontWeight.bold,

              ),

            ),

            const SizedBox(
              height: 10,
            ),

            Text(

              'Your notifications will appear here.',

              textAlign:
                  TextAlign.center,

              style: TextStyle(

                color:
                    Colors.grey.shade600,

                height: 1.5,

              ),

            ),

          ],

        ),

      ),

    );

  }

}
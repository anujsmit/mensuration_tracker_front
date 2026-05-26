// lib/screens/home/user_notifications.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/providers/notification_provider.dart';

class NotificationPage
    extends StatefulWidget {
  const NotificationPage({
    super.key,
  });

  @override
  State<NotificationPage>
      createState() =>
          _NotificationPageState();
}

class _NotificationPageState
    extends State<
        NotificationPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      _loadNotifications();
    });
  }

  // ==========================================
  // LOAD NOTIFICATIONS
  // ==========================================

  Future<void>
      _loadNotifications() async {
    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final notificationProvider =
        Provider.of<
            UserNotificationProvider>(
      context,
      listen: false,
    );

    final token =
        authProvider.token ?? '';

    await notificationProvider
        .fetchNotifications(
      token,
      refresh: true,
    );
  }

  // ==========================================
  // MARK ALL AS READ
  // ==========================================

  Future<void>
      _markAllAsRead() async {
    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final notificationProvider =
        Provider.of<
            UserNotificationProvider>(
      context,
      listen: false,
    );

    final token =
        authProvider.token ?? '';

    try {
      await notificationProvider
          .markAllAsRead(
        token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: const Text(
            'All notifications marked as read',
          ),

          backgroundColor:
              Colors.green,

          behavior:
              SnackBarBehavior
                  .floating,
        ),
      );

    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),

          backgroundColor:
              Colors.red,

          behavior:
              SnackBarBehavior
                  .floating,
        ),
      );
    }
  }

  // ==========================================
  // MARK SINGLE AS READ
  // ==========================================

  Future<void> _markAsRead(
    String id,
  ) async {
    final authProvider =
        Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final notificationProvider =
        Provider.of<
            UserNotificationProvider>(
      context,
      listen: false,
    );

    final token =
        authProvider.token ?? '';

    await notificationProvider
        .markAsRead(
      id,
      token,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primaryColor =
        theme.colorScheme.primary;

    return Consumer<
        UserNotificationProvider>(
      builder: (
        context,
        notificationProvider,
        child,
      ) {
        final notifications =
            notificationProvider
                .notifications;

        return Scaffold(
          backgroundColor:
              const Color(
                  0xFFF6F7FB),

          appBar: AppBar(
            title: const Text(
              'Notifications',
            ),

            centerTitle: true,

            elevation: 0,

            backgroundColor:
                Colors.transparent,

            actions: [
              if (notifications
                  .isNotEmpty)
                TextButton(
                  onPressed:
                      _markAllAsRead,

                  child: Text(
                    'Mark all',

                    style: TextStyle(
                      color:
                          primaryColor,

                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),
            ],
          ),

          body:
              notificationProvider
                      .isLoading
                  ? _buildLoading()
                  : notifications
                          .isEmpty
                      ? _buildEmpty()
                      : RefreshIndicator(
                          onRefresh:
                              _loadNotifications,

                          child:
                              ListView
                                  .builder(
                            padding:
                                const EdgeInsets
                                    .all(
                                        18),

                            itemCount:
                                notifications
                                    .length,

                            itemBuilder:
                                (
                              context,
                              index,
                            ) {
                              final notification =
                                  notifications[
                                      index];

                              return FadeInUp(
                                delay:
                                    Duration(
                                  milliseconds:
                                      index *
                                          70,
                                ),

                                child:
                                    GestureDetector(
                                  onTap:
                                      () async {
                                    if (!notification
                                        .isRead) {
                                      await _markAsRead(
                                        notification
                                            .id,
                                      );
                                    }
                                  },

                                  child:
                                      Container(
                                    margin:
                                        const EdgeInsets
                                            .only(
                                      bottom:
                                          16,
                                    ),

                                    padding:
                                        const EdgeInsets
                                            .all(
                                      18,
                                    ),

                                    decoration:
                                        BoxDecoration(
                                      color:
                                          Colors.white,

                                      borderRadius:
                                          BorderRadius.circular(
                                              24),

                                      border:
                                          notification.isRead
                                              ? null
                                              : Border.all(
                                                  color: primaryColor.withOpacity(
                                                      0.3),
                                                  width:
                                                      1.5,
                                                ),

                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors
                                              .black
                                              .withOpacity(
                                                  0.04),

                                          blurRadius:
                                              10,

                                          offset:
                                              const Offset(
                                                  0,
                                                  5),
                                        ),
                                      ],
                                    ),

                                    child:
                                        Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,

                                      children: [
                                        // ======================
                                        // ICON
                                        // ======================

                                        Container(
                                          padding:
                                              const EdgeInsets
                                                  .all(
                                                      14),

                                          decoration:
                                              BoxDecoration(
                                            color: notification
                                                .color
                                                .withOpacity(
                                                    0.12),

                                            shape:
                                                BoxShape.circle,
                                          ),

                                          child:
                                              Icon(
                                            notification
                                                .iconData,

                                            color:
                                                notification.color,

                                            size:
                                                28,
                                          ),
                                        ),

                                        const SizedBox(
                                            width:
                                                16),

                                        // ======================
                                        // CONTENT
                                        // ======================

                                        Expanded(
                                          child:
                                              Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment
                                                    .start,

                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child:
                                                        Text(
                                                      notification.title,

                                                      style:
                                                          TextStyle(
                                                        fontSize:
                                                            16,

                                                        fontWeight: notification.isRead
                                                            ? FontWeight.w600
                                                            : FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),

                                                  if (!notification
                                                      .isRead)
                                                    Container(
                                                      width:
                                                          10,

                                                      height:
                                                          10,

                                                      decoration:
                                                          BoxDecoration(
                                                        color:
                                                            primaryColor,

                                                        shape:
                                                            BoxShape.circle,
                                                      ),
                                                    ),
                                                ],
                                              ),

                                              const SizedBox(
                                                  height:
                                                      8),

                                              Text(
                                                notification
                                                    .message,

                                                style:
                                                    TextStyle(
                                                  color: Colors
                                                      .grey
                                                      .shade700,

                                                  height:
                                                      1.5,
                                                ),
                                              ),

                                              const SizedBox(
                                                  height:
                                                      14),

                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons
                                                        .access_time_rounded,

                                                    size:
                                                        16,

                                                    color: Colors
                                                        .grey
                                                        .shade500,
                                                  ),

                                                  const SizedBox(
                                                      width:
                                                          6),

                                                  Text(
                                                    notification
                                                        .formatTimeAgo(),

                                                    style:
                                                        TextStyle(
                                                      color: Colors
                                                          .grey
                                                          .shade500,

                                                      fontSize:
                                                          12,
                                                    ),
                                                  ),

                                                  if (notification.senderName !=
                                                      null) ...[
                                                    const SizedBox(
                                                        width:
                                                            12),

                                                    Icon(
                                                      Icons
                                                          .person_outline,

                                                      size:
                                                          16,

                                                      color: Colors
                                                          .grey
                                                          .shade500,
                                                    ),

                                                    const SizedBox(
                                                        width:
                                                            6),

                                                    Expanded(
                                                      child:
                                                          Text(
                                                        notification.senderName!,

                                                        overflow:
                                                            TextOverflow.ellipsis,

                                                        style:
                                                            TextStyle(
                                                          color: Colors
                                                              .grey
                                                              .shade500,

                                                          fontSize:
                                                              12,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
        );
      },
    );
  }

  // ==========================================
  // EMPTY STATE
  // ==========================================

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(
                30),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment
                  .center,

          children: [
            Container(
              height: 120,
              width: 120,

              decoration:
                  BoxDecoration(
                color: Colors
                    .pink
                    .withOpacity(0.1),

                shape:
                    BoxShape.circle,
              ),

              child: const Icon(
                Icons
                    .notifications_off_outlined,

                size: 60,

                color: Colors.pink,
              ),
            ),

            const SizedBox(
                height: 24),

            const Text(
              'No Notifications',

              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 10),

            Text(
              'You currently have no notifications.',

              textAlign:
                  TextAlign.center,

              style: TextStyle(
                color:
                    Colors.grey.shade600,

                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // LOADING
  // ==========================================

  Widget _buildLoading() {
    return const Center(
      child:
          CircularProgressIndicator(),
    );
  }
}
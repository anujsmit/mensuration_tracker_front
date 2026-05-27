// ======================================================
// FILE:
// lib/features/notifications/widgets/notification_tile.dart
// ======================================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/notification_model.dart';

class NotificationTile
    extends StatelessWidget {

  final NotificationModel
      notification;

  final VoidCallback? onTap;

  final VoidCallback? onDelete;

  const NotificationTile({

    super.key,

    required this.notification,

    this.onTap,

    this.onDelete,

  });

  // ======================================================
  // FORMAT DATE
  // ======================================================

  String formatDate(
    DateTime date,
  ) {

    return DateFormat(
      'MMM dd, hh:mm a',
    ).format(date);

  }

  @override
  Widget build(
    BuildContext context,
  ) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        margin:
            const EdgeInsets.only(
          bottom: 14,
        ),

        padding:
            const EdgeInsets.all(
          16,
        ),

        decoration: BoxDecoration(

          color:
              notification.isRead

                  ? Colors.white

                  : Colors.pink.shade50,

          borderRadius:
              BorderRadius.circular(
            22,
          ),

          border: Border.all(

            color:
                notification.isRead

                    ? Colors.grey
                        .shade200

                    : Colors.pink
                        .shade200,

          ),

        ),

        child: Row(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            // ==================================
            // ICON
            // ==================================

            Container(

              padding:
                  const EdgeInsets
                      .all(12),

              decoration:
                  BoxDecoration(

                color: Colors
                    .pink
                    .shade100,

                shape:
                    BoxShape.circle,

              ),

              child: Icon(

                Icons.notifications,

                color:
                    Colors.pink
                        .shade400,

              ),

            ),

            const SizedBox(
              width: 14,
            ),

            // ==================================
            // CONTENT
            // ==================================

            Expanded(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(

                    notification.title,

                    style:
                        TextStyle(

                      fontSize: 16,

                      fontWeight:

                          notification.isRead

                              ? FontWeight
                                  .w600

                              : FontWeight
                                  .bold,

                    ),

                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(

                    notification.message,

                    style: TextStyle(

                      color: Colors
                          .grey
                          .shade700,

                      height: 1.5,

                    ),

                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(

                    formatDate(
                      notification
                          .createdAt,
                    ),

                    style: TextStyle(

                      fontSize: 12,

                      color: Colors
                          .grey
                          .shade500,

                    ),

                  ),

                ],

              ),

            ),

            // ==================================
            // MENU
            // ==================================

            PopupMenuButton(

              itemBuilder:
                  (context) => [

                PopupMenuItem(

                  onTap: onDelete,

                  child: const Row(

                    children: [

                      Icon(
                        Icons.delete,
                        color:
                            Colors.red,
                      ),

                      SizedBox(
                        width: 10,
                      ),

                      Text(
                        'Delete',
                      ),

                    ],

                  ),

                ),

              ],

            ),

          ],

        ),

      ),

    );

  }

}
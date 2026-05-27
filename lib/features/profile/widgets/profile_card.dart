// ======================================================
// FILE:
// lib/features/profile/widgets/profile_card.dart
// ======================================================

import 'package:flutter/material.dart';

import '../models/profile_model.dart';

class ProfileCard
    extends StatelessWidget {

  final ProfileModel profile;

  final VoidCallback? onTap;

  const ProfileCard({

    super.key,

    required this.profile,

    this.onTap,

  });

  @override
  Widget build(
    BuildContext context,
  ) {

    return GestureDetector(

      onTap: onTap,

      child: Container(

        padding:
            const EdgeInsets.all(
          22,
        ),

        decoration: BoxDecoration(

          gradient:
              LinearGradient(

            colors: [

              Colors.pink.shade400,

              Colors.pink.shade200,

            ],

            begin:
                Alignment.topLeft,

            end:
                Alignment.bottomRight,

          ),

          borderRadius:
              BorderRadius.circular(
            28,
          ),

        ),

        child: Row(

          children: [

            // ==================================
            // PROFILE IMAGE
            // ==================================

            CircleAvatar(

              radius: 38,

              backgroundColor:
                  Colors.white,

              backgroundImage:
                  profile.photoUrl !=
                          null

                      ? NetworkImage(
                          profile
                              .photoUrl!,
                        )

                      : null,

              child:
                  profile.photoUrl ==
                          null

                      ? const Icon(
                          Icons.person,
                          size: 38,
                          color:
                              Colors.pink,
                        )

                      : null,

            ),

            const SizedBox(
              width: 18,
            ),

            // ==================================
            // DETAILS
            // ==================================

            Expanded(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(

                    profile.fullName ??
                        'Unknown User',

                    style:
                        const TextStyle(

                      color:
                          Colors.white,

                      fontSize: 22,

                      fontWeight:
                          FontWeight
                              .bold,

                    ),

                  ),

                  const SizedBox(
                    height: 6,
                  ),

                  Text(

                    profile.email ??
                        '',

                    style: TextStyle(

                      color: Colors
                          .white
                          .withOpacity(
                        0.9,
                      ),

                    ),

                  ),

                  if (profile.bio !=
                          null &&
                      profile.bio!
                          .isNotEmpty)

                    Padding(

                      padding:
                          const EdgeInsets
                              .only(
                        top: 10,
                      ),

                      child: Text(

                        profile.bio!,

                        maxLines: 2,

                        overflow:
                            TextOverflow
                                .ellipsis,

                        style:
                            TextStyle(

                          color: Colors
                              .white
                              .withOpacity(
                            0.95,
                          ),

                          height: 1.4,

                        ),

                      ),

                    ),

                ],

              ),

            ),

          ],

        ),

      ),

    );

  }

}
import 'package:flutter/material.dart';

import '../models/profile_model.dart';

class ProfileCard
    extends StatelessWidget {

  final ProfileModel profile;

  final VoidCallback? onEdit;

  const ProfileCard({

    super.key,

    required this.profile,

    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      width: double.infinity,

      padding:
          const EdgeInsets.all(24),

      decoration: BoxDecoration(

        gradient:
            LinearGradient(

          colors: [

            Colors.pink.shade400,

            Colors.pink.shade200,
          ],
        ),

        borderRadius:
            BorderRadius.circular(
          30,
        ),
      ),

      child: Row(

        children: [

          CircleAvatar(

            radius: 42,

            backgroundColor:
                Colors.white,

            backgroundImage:
                profile.avatarUrl !=
                        null

                    ? NetworkImage(
                        profile
                            .avatarUrl!,
                      )

                    : null,

            child:
                profile.avatarUrl ==
                        null

                    ? const Icon(
                        Icons.person,
                        size: 42,
                        color:
                            Colors.pink,
                      )

                    : null,
          ),

          const SizedBox(
            width: 18,
          ),

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

                    fontSize: 24,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(
                  height: 8,
                ),

                const Text(

                  'Menstrual Health Tracker',

                  style: TextStyle(
                    color:
                        Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          IconButton(

            onPressed: onEdit,

            icon: const Icon(
              Icons.edit,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
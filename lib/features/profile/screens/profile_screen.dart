// ======================================================
// FILE:
// lib/features/profile/screens/profile_screen.dart
// ======================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/profile_provider.dart';

import '../widgets/profile_card.dart';

class ProfileScreen
    extends StatefulWidget {

  const ProfileScreen({
    super.key,
  });

  @override
  State<ProfileScreen>
      createState() =>
          _ProfileScreenState();

}

class _ProfileScreenState
    extends State<ProfileScreen> {

  @override
  void initState() {

    super.initState();

    Future.microtask(() {

      Provider.of<ProfileProvider>(
        context,
        listen: false,
      ).fetchProfile();

    });

  }

  @override
  Widget build(
    BuildContext context,
  ) {

    final provider =
        Provider.of<ProfileProvider>(
      context,
    );

    final profile =
        provider.profile;

    return Scaffold(

      backgroundColor:
          const Color(0xFFF6F7FB),

      appBar: AppBar(
        title:
            const Text('Profile'),
      ),

      body:
          provider.isLoading

              ? const Center(
                  child:
                      CircularProgressIndicator(),
                )

              : profile == null

                  ? const Center(
                      child:
                          Text(
                        'No profile found',
                      ),
                    )

                  : SingleChildScrollView(

                      padding:
                          const EdgeInsets
                              .all(20),

                      child: Column(

                        children: [

                          // ======================
                          // CARD
                          // ======================

                          ProfileCard(
                            profile:
                                profile,
                          ),

                          const SizedBox(
                            height: 25,
                          ),

                          // ======================
                          // DETAILS
                          // ======================

                          _buildInfoTile(
                            icon:
                                Icons.person,
                            title:
                                'Username',
                            value:
                                profile
                                        .username ??
                                    '--',
                          ),

                          _buildInfoTile(
                            icon:
                                Icons.phone,
                            title:
                                'Phone',
                            value:
                                profile
                                        .phoneNumber ??
                                    '--',
                          ),

                          _buildInfoTile(
                            icon:
                                Icons.cake,
                            title:
                                'Age',
                            value:
                                profile.age
                                        ?.toString() ??
                                    '--',
                          ),

                          _buildInfoTile(
                            icon:
                                Icons.monitor_weight,
                            title:
                                'Weight',
                            value:
                                profile.weight !=
                                        null
                                    ? '${profile.weight} kg'
                                    : '--',
                          ),

                          _buildInfoTile(
                            icon:
                                Icons.height,
                            title:
                                'Height',
                            value:
                                profile.height !=
                                        null
                                    ? '${profile.height} cm'
                                    : '--',
                          ),

                          const SizedBox(
                            height: 30,
                          ),

                          // ======================
                          // DELETE
                          // ======================

                          SizedBox(

                            width:
                                double.infinity,

                            height: 56,

                            child:
                                ElevatedButton(

                              onPressed:
                                  () async {

                                final confirm =
                                    await showDialog<bool>(

                                  context:
                                      context,

                                  builder:
                                      (_) {

                                    return AlertDialog(

                                      title:
                                          const Text(
                                        'Delete Account',
                                      ),

                                      content:
                                          const Text(
                                        'Are you sure?',
                                      ),

                                      actions: [

                                        TextButton(

                                          onPressed:
                                              () {

                                            Navigator.pop(
                                              context,
                                              false,
                                            );

                                          },

                                          child:
                                              const Text(
                                            'Cancel',
                                          ),

                                        ),

                                        ElevatedButton(

                                          onPressed:
                                              () {

                                            Navigator.pop(
                                              context,
                                              true,
                                            );

                                          },

                                          child:
                                              const Text(
                                            'Delete',
                                          ),

                                        ),

                                      ],

                                    );

                                  },

                                );

                                if (confirm !=
                                    true) {
                                  return;
                                }

                                await provider
                                    .deleteAccount();

                              },

                              style:
                                  ElevatedButton
                                      .styleFrom(

                                backgroundColor:
                                    Colors.red,

                              ),

                              child:
                                  const Text(
                                'DELETE ACCOUNT',
                              ),

                            ),

                          ),

                        ],

                      ),

                    ),

    );

  }

  // ======================================================
  // INFO TILE
  // ======================================================

  Widget _buildInfoTile({

    required IconData icon,

    required String title,

    required String value,

  }) {

    return Container(

      margin:
          const EdgeInsets.only(
        bottom: 16,
      ),

      padding:
          const EdgeInsets.all(
        18,
      ),

      decoration: BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          22,
        ),

      ),

      child: Row(

        children: [

          Container(

            padding:
                const EdgeInsets
                    .all(12),

            decoration:
                BoxDecoration(

              color: Colors
                  .pink
                  .shade50,

              shape:
                  BoxShape.circle,

            ),

            child: Icon(
              icon,
              color:
                  Colors.pink,
            ),

          ),

          const SizedBox(
            width: 16,
          ),

          Expanded(

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(

                  title,

                  style: TextStyle(
                    color: Colors
                        .grey
                        .shade600,
                  ),

                ),

                const SizedBox(
                  height: 4,
                ),

                Text(

                  value,

                  style:
                      const TextStyle(

                    fontWeight:
                        FontWeight
                            .bold,

                    fontSize: 16,

                  ),

                ),

              ],

            ),

          ),

        ],

      ),

    );

  }

}
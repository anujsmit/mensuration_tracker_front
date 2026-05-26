import 'package:flutter/material.dart';

class VerifyEmailScreen
    extends StatelessWidget {
  final String email;

  const VerifyEmailScreen({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF6F7FB),

      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              Container(
                height: 120,
                width: 120,

                decoration:
                    BoxDecoration(
                  color:
                      Colors.pink.shade100,
                  shape: BoxShape.circle,
                ),

                child: Icon(
                  Icons.mark_email_read,
                  size: 60,
                  color: Colors.pink.shade600,
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Verify Your Email',

                style: TextStyle(
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                'We sent a verification link to:\n$email',

                textAlign:
                    TextAlign.center,

                style: TextStyle(
                  fontSize: 16,
                  color:
                      Colors.grey.shade700,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'Please check your inbox and verify your email before logging in.',

                textAlign:
                    TextAlign.center,
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 56,

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.pink,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              18),
                    ),
                  ),

                  child: const Text(
                    'BACK TO LOGIN',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
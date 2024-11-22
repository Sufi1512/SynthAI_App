import 'package:flutter/material.dart';

class UpgradeToPremiumPage extends StatelessWidget {
  const UpgradeToPremiumPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 16),
          child: Center(
            child: Text(
              'Upgrade to Premium',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment:
              MainAxisAlignment.start, // Ensure everything is at the top
          children: [
            const SizedBox(height: 10),
            const Center(
              child: Text(
                'Enjoy exclusive features with the premium version of SynthAI Suite!',
                style: TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 30),
            Center(
              // Wrap Button in Center to ensure it is centered horizontally
              child: ElevatedButton(
                onPressed: () {
                  // Dummy action for now
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Upgrade'),
                      content:
                          const Text('Thank you for upgrading to premium!'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('Close'),
                        ),
                      ],
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Upgrade Now',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

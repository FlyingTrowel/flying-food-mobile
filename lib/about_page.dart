import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _url = Uri.parse('https://github.com/FlyingTrowel/flying-food-mobile');

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // App logo
            Image.asset(
              'assets/ff.png', // Make sure to add your app logo image in the assets directory and update the path
              height: 200,
            ),
            const SizedBox(height: 20),
            // Clickable link to the app website
            ElevatedButton.icon(
              onPressed: _launchUrl,
              icon: const Icon(Icons.code),
              label: const Text('Flying Food Website'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange[300],
                foregroundColor: Colors.black
              ),// Clear label for the link
            ),
            const SizedBox(height: 30),
            // List of group members
            const Text(
              'RCDCS251 5B',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'AIMAN BAZLI BIN ROSLAN 2023305751\n'
                  'AIEMAN NUR HAKIM BIN ROSLAN 2023376281\n'
                  'MUHAMMAD HAKIMI BIN SAMSURI 2023379837\n'
                  'MUHAMMAD IRFANNUDDIN BIN GAFRI 2023375241',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            // Copyright information
            const Text(
              'Flying Food© 2024',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

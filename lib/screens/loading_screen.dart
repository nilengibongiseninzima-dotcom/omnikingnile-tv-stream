import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              strokeWidth: 4,
            ),
            const SizedBox(height: 24),
            Text(
              'Loading Channels...',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Please wait while we fetch your playlist',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
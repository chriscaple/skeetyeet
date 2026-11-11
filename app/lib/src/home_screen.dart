import 'package:flutter/material.dart';

/// First-run screen: no accounts connected yet.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        const TextSpan(text: 'Skeet'),
                        TextSpan(
                          text: 'Yeet',
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ],
                    ),
                    style: theme.textTheme.displaySmall,
                    semanticsLabel: 'SkeetYeet',
                  ),
                  const SizedBox(height: 24),
                  Semantics(
                    label: 'A tuft of grass under a warm sun',
                    image: true,
                    child: Image.asset(
                      'assets/illustrations/touch-grass.png',
                      width: 240,
                      height: 240,
                      excludeFromSemantics: true,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Your timeline, your rules.\n'
                    'What are we letting go of today?',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Account sign-in arrives in the next build. Hang loose!',
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Connect a Bluesky account'),
                  ),
                  const SizedBox(height: 40),
                  Text(
                    'Everything stays on this device. '
                    'SkeetYeet is not affiliated with Bluesky Social PBC.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(
                        alpha: 0.75,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

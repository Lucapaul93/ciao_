import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../widgets/screen_with_particles.dart';
import '../widgets/back_button.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  // URL per la tua privacy policy online
  // Sostituisci questo con l'URL della tua privacy policy
  static const String privacyPolicyUrl =
      'https://lucapaul93.github.io/lullaby-privacy/';

  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() {
                  isLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  isLoading = false;
                });
              },
            ),
          )
          ..loadRequest(Uri.parse(privacyPolicyUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ScreenWithParticles(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        'Privacy Policy',
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          children: [
                            WebViewWidget(controller: controller),
                            if (isLoading)
                              const Center(child: CircularProgressIndicator()),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const CustomBackButton(),
            ],
          ),
        ),
      ),
    );
  }
}

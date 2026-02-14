import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/constants/env.dart';
import 'core/theme.dart';
import 'backend/data/auth_service.dart';
import 'painters/space_invader_painter.dart';
import 'ui/screens/landing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file for local development
  await dotenv.load(fileName: '.env');

  // Initialize Supabase
  if (Env.isSupabaseConfigured) {
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
    );

    // Initialize AuthService to check for existing session
    await AuthService().initialize();
  } else {
    debugPrint('WARNING: Supabase environment variables not configured');
    debugPrint('Missing: ${Env.getMissingVars()}');
    debugPrint('App will run but authentication and orders will not work');
  }

  runApp(const MerchRedemptionApp());
}

class MerchRedemptionApp extends StatelessWidget {
  const MerchRedemptionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CITRIS Quest Merch Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.dark(
          primary: AppTheme.bluePrimary,
          secondary: AppTheme.cyanAccent,
          surface: AppTheme.backgroundSecondary,
        ),
        scaffoldBackgroundColor: AppTheme.backgroundPrimary,
      ),
      home: const _FontLoader(),
    );
  }
}

/// Loading screen that preloads Google Fonts before showing the app
class _FontLoader extends StatefulWidget {
  const _FontLoader();

  @override
  State<_FontLoader> createState() => _FontLoaderState();
}

class _FontLoaderState extends State<_FontLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Future<void> _fontFuture;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Trigger font preloading
    _fontFuture = _preloadFonts();
  }

  Future<void> _preloadFonts() async {
    // Trigger font downloads by creating text painters
    GoogleFonts.tiny5();
    GoogleFonts.silkscreen();
    // Wait for all pending font loads to complete
    await GoogleFonts.pendingFonts();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _fontFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return const LandingScreen();
        }

        // Loading screen
        return Scaffold(
          backgroundColor: AppTheme.backgroundPrimary,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Space Invader icon with pulsing glow
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final glowAlpha = 0.2 + (_pulseController.value * 0.4);
                    return Container(
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.cyanAccent
                                .withValues(alpha: glowAlpha),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: CustomPaint(
                        size: const Size(66, 48),
                        painter: SpaceInvaderPainter(
                          color: AppTheme.cyanAccent,
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 32),
                // Loading text (uses default font since custom fonts aren't loaded yet)
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Opacity(
                      opacity: 0.5 + (_pulseController.value * 0.5),
                      child: const Text(
                        'LOADING...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

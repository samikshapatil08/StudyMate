import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme.dart';
import 'focus_timer_screen.dart';
import 'streaks_screen.dart';
import 'cat_screen.dart';
import 'fact_screen.dart';

class FunHomeScreen extends StatelessWidget {
  const FunHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

  
    final width = MediaQuery.of(context).size.width;
    final int crossAxisCount = width > 1000
        ? 4
        : width > 600
            ? 3
            : 2;

    final double fontScale = (width / 400).clamp(0.85, 1.2);
    
   
    final double aspectRatio = width < 350 ? 0.8 : 1.0;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Fun Zone",
                      style: GoogleFonts.inter(
                        fontSize: 24 * fontScale, 
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GridView.count(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: aspectRatio, 
                    children: [
                      _FunCard(
                        title: "Focus Timer",
                        icon: Icons.timer,
                        color: AppTheme.primaryPurple,
                        fontScale: fontScale,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FocusTimerScreen())),
                      ),
                      _FunCard(
                        title: "Daily Streaks",
                        icon: Icons.local_fire_department,
                        color: AppTheme.accentRed,
                        fontScale: fontScale,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const StreaksScreen())),
                      ),
                      _FunCard(
                        title: "Cat Generator",
                        icon: Icons.pets,
                        color: AppTheme.secondaryBlue,
                        fontScale: fontScale,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const CatScreen())),
                      ),
                      _FunCard(
                        title: "Useless Facts",
                        icon: Icons.lightbulb,
                        color: AppTheme.accentYellow,
                        fontScale: fontScale,
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FactScreen())),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FunCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final double fontScale; 
  final VoidCallback onTap;

  const _FunCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.fontScale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32 * fontScale, color: color), 
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w600,
                  fontSize: 14 * fontScale, 
                  color: theme.textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
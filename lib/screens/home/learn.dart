import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class LearnPage extends StatefulWidget {
  const LearnPage({super.key});

  @override
  State<LearnPage> createState() => _LearnPageState();
}

class _LearnPageState extends State<LearnPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late YoutubePlayerController _youtubeController;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();

    _initYoutubePlayer();
  }

  void _initYoutubePlayer() {
    try {
      final videoId = YoutubePlayer.convertUrlToId(
            'https://www.youtube.com/watch?v=JMeKBKe2NVw',
          ) ??
          'JMeKBKe2NVw';

      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          enableCaption: true,
          hideControls: false,
          hideThumbnail: false,
        ),
      );
    } catch (e) {
      print('Error initializing YouTube player: $e');
      // Fallback to a default video ID if conversion fails
      _youtubeController = YoutubePlayerController(
        initialVideoId: 'JMeKBKe2NVw',
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          enableCaption: true,
          hideControls: false,
          hideThumbnail: false,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _youtubeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menstrual Education'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeTransition(
              opacity: _animation,
              child: _buildSectionHeader(
                title: "Understanding Menstruation",
                icon: Icons.health_and_safety,
                theme: theme,
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _animation,
              child: _buildInfoCard(
                title: "What is a Period?",
                content:
                    "Menstruation (period) is the monthly shedding of the uterine lining. It's part of the menstrual cycle that prepares your body for pregnancy each month.",
                icon: Icons.help_outline,
                color: colors.primary,
                theme: theme,
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _animation,
              child: _buildInfoCard(
                title: "How Does It Occur?",
                content:
                    "Each month, hormones cause the lining of the uterus to thicken in preparation for a fertilized egg. When pregnancy doesn't occur, hormone levels drop, causing the lining to shed.",
                icon: Icons.science,
                color: colors.secondary,
                theme: theme,
              ),
            ),
            const SizedBox(height: 16),
            _buildVideoPlayer(colors, theme),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _animation,
              child: _buildSectionHeader(
                title: "The Menstrual Cycle",
                icon: Icons.cyclone,
                theme: theme,
              ),
            ),
            const SizedBox(height: 16),
            FadeTransition(
              opacity: _animation,
              child: _buildCyclePhaseCard(
                phase: "Menstrual Phase (Days 1-5)",
                description:
                    "The uterine lining sheds through the vagina. Typically lasts 3-7 days.",
                symptoms: "Cramps, bloating, fatigue",
                color: colors.primary,
                theme: theme,
              ),
            ),
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _animation,
              child: _buildCyclePhaseCard(
                phase: "Follicular Phase (Days 6-14)",
                description:
                    "The pituitary gland releases FSH, stimulating follicles in the ovaries. One follicle matures into an egg.",
                symptoms: "Increasing energy, improved mood",
                color: colors.tertiary,
                theme: theme,
              ),
            ),
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _animation,
              child: _buildCyclePhaseCard(
                phase: "Ovulation (Day 14)",
                description:
                    "The ovary releases a mature egg which travels down the fallopian tube toward the uterus.",
                symptoms: "Mild pelvic pain, increased libido",
                color: colors.secondary,
                theme: theme,
              ),
            ),
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _animation,
              child: _buildCyclePhaseCard(
                phase: "Luteal Phase (Days 15-28)",
                description:
                    "If the egg isn't fertilized, hormone levels drop and the uterine lining begins to break down.",
                symptoms: "PMS, breast tenderness, mood swings",
                color: colors.primaryContainer,
                theme: theme,
              ),
            ),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _animation,
              child: _buildSectionHeader(
                title: "Period Facts",
                icon: Icons.lightbulb_outline,
                theme: theme,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              "The average menstrual cycle is 28 days, but normal cycles range from 21-35 days.",
              "Periods typically last 3-7 days, with the heaviest flow in the first 2-3 days.",
              "You lose about 30-40ml (2-3 tablespoons) of blood during a normal period.",
              "Exercise and a balanced diet can help alleviate menstrual cramps."
            ]
                .map((fact) => FadeTransition(
                      opacity: _animation,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: _buildFactItem(fact: fact, theme: theme),
                      ),
                    ))
                .toList(),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _animation,
              child: _buildSectionHeader(
                title: "When to See a Doctor",
                icon: Icons.medical_services,
                theme: theme,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              "Extreme pain that prevents normal activities",
              "Bleeding that lasts more than 7 days",
              "Periods that are less than 21 days apart",
              "No period by age 15 or within 3 years of breast development"
            ]
                .map((warning) => FadeTransition(
                      opacity: _animation,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child:
                            _buildWarningCard(content: warning, theme: theme),
                      ),
                    ))
                .toList(),
            const SizedBox(height: 24),
            FadeTransition(
              opacity: _animation,
              child: Text(
                "Remember: Every body is different. Your cycle is unique to you!",
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontStyle: FontStyle.italic,
                  color: colors.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Center(
              child: FadeTransition(
                opacity: _animation,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text('Back to Home'),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(ColorScheme colors, ThemeData theme) {
    return FadeTransition(
      opacity: _animation,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                "Educational Video",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _isPlayerReady
                      ? YoutubePlayer(
                          controller: _youtubeController,
                          aspectRatio: 16 / 9,
                          showVideoProgressIndicator: true,
                          progressIndicatorColor: colors.primary,
                          progressColors: ProgressBarColors(
                            playedColor: colors.primary,
                            handleColor: colors.primary,
                            bufferedColor: colors.primary.withOpacity(0.3),
                            backgroundColor: colors.primary.withOpacity(0.1),
                          ),
                          onReady: () {
                            setState(() => _isPlayerReady = true);
                          },
                        )
                      : Container(
                          height: 200,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required ThemeData theme,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
          border: Border(
        bottom: BorderSide(
            color: theme.colorScheme.primary.withOpacity(0.2), width: 2),
      )),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Card(
      elevation: 2,
      shadowColor: color.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCyclePhaseCard({
    required String phase,
    required String description,
    required String symptoms,
    required Color color,
    required ThemeData theme,
  }) {
    return Card(
      elevation: 1,
      shadowColor: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    phase,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline,
                    size: 18, color: theme.colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Common symptoms: $symptoms",
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFactItem({
    required String fact,
    required ThemeData theme,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 6),
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            fact,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningCard({
    required String content,
    required ThemeData theme,
  }) {
    return Card(
      elevation: 1,
      shadowColor: theme.colorScheme.error.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded,
                color: theme.colorScheme.onErrorContainer, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                content,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onErrorContainer,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
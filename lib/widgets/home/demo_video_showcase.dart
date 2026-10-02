import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme.dart';
import '../animations/floating_widget.dart';
import '../responsive_layout.dart';

/// Interactive Demo Video Showcase Component
/// Simulates an authentic cinema-grade video product walkthrough
/// demonstrating how WhiskerWorld helps adopters, owners, and pet stores.
class DemoVideoShowcase extends StatefulWidget {
  const DemoVideoShowcase({super.key});

  @override
  State<DemoVideoShowcase> createState() => _DemoVideoShowcaseState();
}

class _DemoVideoShowcaseState extends State<DemoVideoShowcase> with SingleTickerProviderStateMixin {
  bool _isPlaying = false;
  bool _isMuted = false;
  int _currentChapter = 0;
  double _playbackProgress = 0.0; // 0.0 to 1.0
  Timer? _playbackTimer;

  static const int _totalSeconds = 80; // 1:20 total walkthrough length
  static const int _secondsPerChapter = 20;

  final List<Map<String, dynamic>> _chapters = [
    {
      'id': 0,
      'title': 'Smart Companion Discovery',
      'shortTitle': 'Discovery',
      'tagline': 'Pediatric Health & Verified Listings',
      'duration': '0:00 - 0:20',
      'icon': Icons.pets_rounded,
      'accent': Color(0xFFFF6B6B),
      'description':
          'Browse certified puppies, kittens, and young companions with transparent health passports, core vaccines, and zero puppy mills.',
      'benefits': [
        'Pediatric veterinary inspection tags',
        'Transparent parentage and health history',
        'Species, age, and breed smart filters',
      ],
    },
    {
      'id': 1,
      'title': 'Live Interactive Pet Map',
      'shortTitle': 'Interactive Map',
      'tagline': 'Geolocate Stores, Owners & Chosen Pet',
      'duration': '0:20 - 0:40',
      'icon': Icons.map_rounded,
      'accent': Color(0xFF0D9488),
      'description':
          'Explore certified pet stores and pet owners directly on our live OpenStreetMap. Select your chosen companion to see a direct route connecting pet to caregiver.',
      'benefits': [
        'Emerald pins for certified pet stores',
        'Coral pins for verified individual pet owners',
        'Pulsing gold pin & polyline route to your chosen pet',
      ],
    },
    {
      'id': 2,
      'title': 'Direct Application & Caregiver Chat',
      'shortTitle': 'Application & Chat',
      'tagline': 'Safe Communication & Fast Approval',
      'duration': '0:40 - 1:00',
      'icon': Icons.chat_bubble_rounded,
      'accent': Color(0xFF2563EB),
      'description':
          'Submit a comprehensive lifestyle questionnaire directly to caregivers and chat seamlessly to arrange meet-and-greets.',
      'benefits': [
        'Standardized ethical adoption questionnaires',
        'Direct in-app messaging with owners and stores',
        'Real-time application status tracking',
      ],
    },
    {
      'id': 3,
      'title': 'Certified Vet Passport & Homecoming',
      'shortTitle': 'Vet Passport',
      'tagline': 'Final Documentation & Safe Adoption',
      'duration': '1:00 - 1:20',
      'icon': Icons.verified_user_rounded,
      'accent': Color(0xFF7C3AED),
      'description':
          'Finalize your adoption securely, download digital pediatric veterinary passports, and receive lifetime pet care onboarding resources.',
      'benefits': [
        'Digital microchip and vaccine records',
        'Certified adoption certificates',
        'Pediatric transition and nutrition checklists',
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
    });

    if (_isPlaying) {
      _startPlayback();
    } else {
      _playbackTimer?.cancel();
    }
  }

  void _startPlayback() {
    _playbackTimer?.cancel();
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!mounted) return;
      setState(() {
        _playbackProgress += (0.2 / _totalSeconds);
        if (_playbackProgress >= 1.0) {
          _playbackProgress = 0.0;
          _currentChapter = 0;
          _isPlaying = false;
          _playbackTimer?.cancel();
        } else {
          final chapterIndex = (_playbackProgress * _chapters.length).floor().clamp(0, _chapters.length - 1);
          if (chapterIndex != _currentChapter) {
            _currentChapter = chapterIndex;
          }
        }
      });
    });
  }

  void _jumpToChapter(int index) {
    setState(() {
      _currentChapter = index;
      _playbackProgress = (index * _secondsPerChapter) / _totalSeconds;
      if (!_isPlaying) {
        _isPlaying = true;
        _startPlayback();
      }
    });
  }

  void _seekTo(double progress) {
    setState(() {
      _playbackProgress = progress.clamp(0.0, 1.0);
      _currentChapter = (_playbackProgress * _chapters.length).floor().clamp(0, _chapters.length - 1);
    });
  }

  String _formatTime(double progress) {
    final currentSec = (progress * _totalSeconds).round();
    final mins = currentSec ~/ 60;
    final secs = currentSec % 60;
    return '${mins.toString().padLeft(1, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    final isDark = AppTheme.isDark(context);
    final currentCh = _chapters[_currentChapter];
    final accentColor = currentCh['accent'] as Color;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(isMobile ? 24 : 32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 36,
            spreadRadius: 2,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // 1. TOP VIDEO HEADER
          _buildVideoHeader(context, isMobile, currentCh, accentColor),

          // 2. MAIN VIDEO STAGE / SCREEN
          _buildVideoStage(context, isMobile, currentCh, accentColor),

          // 3. TRANSPORT CONTROL BAR & SCRUBBER
          _buildVideoControls(context, isMobile, accentColor),

          // 4. CHAPTER NAVIGATION TABS
          _buildChapterTabs(context, isMobile, accentColor),
        ],
      ),
    );
  }

  Widget _buildVideoHeader(BuildContext context, bool isMobile, Map<String, dynamic> currentCh, Color accentColor) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: _isPlaying ? Colors.redAccent : Colors.amberAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (_isPlaying ? Colors.redAccent : Colors.amberAccent).withValues(alpha: 0.6),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'WHISKERWORLD PRODUCT WALKTHROUGH',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: isMobile ? 11 : 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(currentCh['icon'] as IconData, size: 14, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  'SCENE ${_currentChapter + 1}/4',
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoStage(BuildContext context, bool isMobile, Map<String, dynamic> currentCh, Color accentColor) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: isMobile ? 320 : 420),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF0F172A),
            accentColor.withValues(alpha: 0.15),
            const Color(0xFF1E293B),
          ],
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background Atmospheric Watermark
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              currentCh['icon'] as IconData,
              size: isMobile ? 160 : 260,
              color: Colors.white.withValues(alpha: 0.04),
            ),
          ),

          // Scene Animated Content
          Padding(
            padding: EdgeInsets.all(isMobile ? 20.0 : 36.0),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.05, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _buildSceneContent(context, isMobile, currentCh, accentColor),
            ),
          ),

          // Big Center Play/Pause Overlay if Paused
          if (!_isPlaying)
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
              ),
              child: Center(
                child: FloatingWidget(
                  verticalDistance: 6,
                  duration: const Duration(milliseconds: 2400),
                  child: GestureDetector(
                    onTap: _togglePlayPause,
                    child: Container(
                      width: isMobile ? 68 : 84,
                      height: isMobile ? 68 : 84,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [accentColor, accentColor.withValues(alpha: 0.8)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.5),
                            blurRadius: 28,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 46,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSceneContent(BuildContext context, bool isMobile, Map<String, dynamic> currentCh, Color accentColor) {
    switch (_currentChapter) {
      case 0:
        return _buildScene1Discovery(context, isMobile, currentCh, accentColor);
      case 1:
        return _buildScene2Map(context, isMobile, currentCh, accentColor);
      case 2:
        return _buildScene3Chat(context, isMobile, currentCh, accentColor);
      case 3:
      default:
        return _buildScene4Passport(context, isMobile, currentCh, accentColor);
    }
  }

  // Scene 1: Smart Companion Discovery
  Widget _buildScene1Discovery(BuildContext context, bool isMobile, Map<String, dynamic> currentCh, Color accentColor) {
    return Column(
      key: const ValueKey('scene_discovery'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSceneHeader(currentCh, accentColor),
        const SizedBox(height: 20),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildSimulationPetCard(
              name: 'Bruno',
              species: 'Golden Retriever Puppy',
              age: '10 Weeks',
              badge: 'Pediatric Vet Cleared',
              color: const Color(0xFFF59E0B),
              icon: Icons.verified_rounded,
            ),
            _buildSimulationPetCard(
              name: 'Luna',
              species: 'Calico Baby Kitten',
              age: '8 Weeks',
              badge: 'Vaccinated & Microchipped',
              color: const Color(0xFF10B981),
              icon: Icons.health_and_safety_rounded,
            ),
            if (!isMobile)
              _buildSimulationPetCard(
                name: 'Milo',
                species: 'French Bulldog Pup',
                age: '12 Weeks',
                badge: 'Ethical Home Reared',
                color: const Color(0xFF3B82F6),
                icon: Icons.home_rounded,
              ),
          ],
        ),
      ],
    );
  }

  // Scene 2: Live Interactive Pet Map
  Widget _buildScene2Map(BuildContext context, bool isMobile, Map<String, dynamic> currentCh, Color accentColor) {
    return Column(
      key: const ValueKey('scene_map'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSceneHeader(currentCh, accentColor),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMapLegendItem('Pet Stores (Emerald)', Icons.storefront_rounded, const Color(0xFF0D9488)),
                  _buildMapLegendItem('Pet Owners (Coral)', Icons.person_pin_circle_rounded, const Color(0xFFFF6B6B)),
                  _buildMapLegendItem('Chosen Pet (Gold)', Icons.pets_rounded, const Color(0xFFF59E0B)),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.alt_route_rounded, color: Color(0xFF0D9488), size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Active Route: Tracking Bruno (Puppy) -> Whisker Haven Sanctuary (1.4 mi)',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: isMobile ? 12 : 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => context.go('/map'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Try Live Map', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Scene 3: Direct Application & Caregiver Chat
  Widget _buildScene3Chat(BuildContext context, bool isMobile, Map<String, dynamic> currentCh, Color accentColor) {
    return Column(
      key: const ValueKey('scene_chat'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSceneHeader(currentCh, accentColor),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Column(
            children: [
              _buildChatBubble(
                sender: 'Eleanor Vance (Verified Owner)',
                message: 'Hello! Bruno loves running around our yard. He is ready for a home with loving care!',
                time: '10:14 AM',
                isOwner: true,
              ),
              const SizedBox(height: 10),
              _buildChatBubble(
                sender: 'You (Adopter)',
                message: 'We have a fenced garden and work remotely! We just submitted the adoption questionnaire.',
                time: '10:15 AM',
                isOwner: false,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 14, color: Color(0xFF10B981)),
                        SizedBox(width: 6),
                        Text('Application Approved', style: TextStyle(color: Color(0xFF10B981), fontSize: 11, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Scene 4: Certified Vet Passport & Homecoming
  Widget _buildScene4Passport(BuildContext context, bool isMobile, Map<String, dynamic> currentCh, Color accentColor) {
    return Column(
      key: const ValueKey('scene_passport'),
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSceneHeader(currentCh, accentColor),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF7C3AED).withValues(alpha: 0.4)),
                ),
                child: const Icon(Icons.badge_rounded, color: Color(0xFF7C3AED), size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Official WhiskerWorld Adoption Passport #WW-89241',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 13 : 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Includes DHPP vaccine record, ISO microchip certificate, and 30-day health warranty.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                onPressed: () => context.go('/pets'),
                icon: const Icon(Icons.favorite_rounded, size: 16),
                label: const Text('Adopt Today'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSceneHeader(Map<String, dynamic> currentCh, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                currentCh['tagline'] as String,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          currentCh['title'] as String,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          currentCh['description'] as String,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.8),
            fontSize: 14,
            height: 1.45,
          ),
        ),
      ],
    );
  }

  Widget _buildSimulationPetCard({
    required String name,
    required String species,
    required String age,
    required String badge,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8)),
                child: Text(age, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(species, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 12)),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  badge,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMapLegendItem(String label, IconData icon, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildChatBubble({
    required String sender,
    required String message,
    required String time,
    required bool isOwner,
  }) {
    return Align(
      alignment: isOwner ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isOwner ? Colors.white.withValues(alpha: 0.12) : const Color(0xFF2563EB).withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isOwner ? Colors.white.withValues(alpha: 0.15) : const Color(0xFF2563EB).withValues(alpha: 0.5),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(sender, style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Text(time, style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10)),
              ],
            ),
            const SizedBox(height: 4),
            Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  // 3. TRANSPORT CONTROL BAR
  Widget _buildVideoControls(BuildContext context, bool isMobile, Color accentColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 20, vertical: 10),
      color: Colors.black.withValues(alpha: 0.6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Interactive Scrubber Bar
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: accentColor,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.2),
              thumbColor: accentColor,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: _playbackProgress.clamp(0.0, 1.0),
              onChanged: (val) => _seekTo(val),
            ),
          ),

          // Control buttons and time indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    tooltip: _isPlaying ? 'Pause' : 'Play',
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() => _isMuted = !_isMuted);
                    },
                    icon: Icon(
                      _isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 20,
                    ),
                    tooltip: _isMuted ? 'Unmute' : 'Mute',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_formatTime(_playbackProgress)} / 01:20',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      '4K UHD',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _showFullscreenModal(context),
                    icon: const Icon(Icons.fullscreen_rounded, color: Colors.white, size: 24),
                    tooltip: 'Fullscreen View',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. CHAPTER NAVIGATION TABS
  Widget _buildChapterTabs(BuildContext context, bool isMobile, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: Colors.black.withValues(alpha: 0.4),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _chapters.map((ch) {
            final idx = ch['id'] as int;
            final isSelected = idx == _currentChapter;
            final chAccent = ch['accent'] as Color;

            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: InkWell(
                onTap: () => _jumpToChapter(idx),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? chAccent.withValues(alpha: 0.25) : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? chAccent : Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(ch['icon'] as IconData, size: 14, color: isSelected ? chAccent : Colors.white70),
                      const SizedBox(width: 8),
                      Text(
                        '${idx + 1}. ${ch['shortTitle']}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white70,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showFullscreenModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: const DemoVideoShowcase(),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../widgets/health_overview_card.dart';
import '../widgets/quick_action_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/backend_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String userName = "User";
  String greeting = 'Good Morning';
  bool isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _updateGreeting();
    _loadCachedUserName().then((_) => _loadUserNameFromBackend());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadCachedUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedName = prefs.getString('userName');
    if (cachedName != null) {
      setState(() {
        userName = cachedName;
        isLoading = false;
      });
    }
  }

  Future<void> _loadUserNameFromBackend() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final token = await user.getIdToken(true);
        final profile = await BackendService(
                baseUrl: "https://healthmatex-backend.onrender.com")
            .getUserProfile(uid: user.uid, firebaseIdToken: token!);

        final nameFromBackend = profile['name'] ?? 'User';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', nameFromBackend);

        setState(() {
          userName = nameFromBackend;
          isLoading = false;
        });
      } catch (e) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      }
    }
  }

  void _updateGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      greeting = 'Good Morning';
    } else if (hour >= 12 && hour < 17) {
      greeting = 'Good Afternoon';
    } else if (hour >= 17 && hour < 21) {
      greeting = 'Good Evening';
    } else {
      greeting = 'Good Night';
    }
  }

  IconData _getGreetingIcon() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return Icons.wb_sunny;
    } else if (hour >= 12 && hour < 17) {
      return Icons.wb_sunny_outlined;
    } else if (hour >= 17 && hour < 21) {
      return Icons.nights_stay;
    } else {
      return Icons.bedtime;
    }
  }

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF2684FF);
    final currentDate = DateFormat('EEEE, MMMM d').format(DateTime.now());

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF121212) : const Color(0xFFF7F8FA);

// Adaptive status bar style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Header with Gradient
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: isDark
                          ? [blue.withOpacity(0.6), blue.withOpacity(0.4)]
                          : [blue, blue.withOpacity(0.85)],
                    ),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: blue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      MediaQuery.of(context).padding.top +
                          10, // dynamic top padding
                      20,
                      30,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Row: Greeting Icon and Notification
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                _getGreetingIcon(),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            Stack(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                Positioned(
                                  right: 8,
                                  top: 8,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFFF6B6B),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Greeting Text
                        Text(
                          greeting,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isLoading ? 'Loading...' : userName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 32,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              currentDate,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Health Overview Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.analytics_outlined,
                                  color: blue,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'Health Overview',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF262A31),
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {},
                            child: Text(
                              'View All',
                              style: TextStyle(
                                color: blue,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Health Cards Grid
                      GridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        childAspectRatio: 1.35,
                        children: [
                          _buildEnhancedHealthCard(
                            icon: Icons.water_drop,
                            title: "Diabetes",
                            subtitle: "Normal",
                            value: "95 mg/dL",
                            iconColor: const Color(0xFF24CB59),
                            bgColor: const Color(0xFF24CB59).withOpacity(0.1),
                            isDark: isDark,
                          ),
                          _buildEnhancedHealthCard(
                            icon: Icons.favorite,
                            title: "Cholesterol",
                            subtitle: "Borderline",
                            value: "210 mg/dL",
                            iconColor: const Color(0xFFFFAC41),
                            bgColor: const Color(0xFFFFAC41).withOpacity(0.1),
                            isDark: isDark,
                          ),
                          _buildEnhancedHealthCard(
                            icon: Icons.spa,
                            title: "Kidney",
                            subtitle: "Normal",
                            value: "1.1 mg/dL",
                            iconColor: const Color(0xFF52C4A2),
                            bgColor: const Color(0xFF52C4A2).withOpacity(0.1),
                            isDark: isDark,
                          ),
                          _buildEnhancedHealthCard(
                            icon: Icons.monitor_heart,
                            title: "Liver",
                            subtitle: "Normal",
                            value: "35 U/L",
                            iconColor: const Color(0xFF57C1F3),
                            bgColor: const Color(0xFF57C1F3).withOpacity(0.1),
                            isDark: isDark,
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // Quick Actions Section
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7357DA).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.flash_on,
                              color: Color(0xFF7357DA),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Quick Actions',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF262A31),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Enhanced Quick Action Cards
                      _buildEnhancedQuickAction(
                        icon: Icons.camera_alt,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF2684FF),
                            const Color(0xFF2684FF).withOpacity(0.8),
                          ],
                        ),
                        title: 'Scan New Report',
                        subtitle: 'Upload and analyze lab results',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildEnhancedQuickAction(
                        icon: Icons.history,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF7357DA),
                            const Color(0xFF7357DA).withOpacity(0.8),
                          ],
                        ),
                        title: 'View History',
                        subtitle: 'See your past reports',
                        onTap: () {},
                      ),
                      const SizedBox(height: 12),
                      _buildEnhancedQuickAction(
                        icon: Icons.lightbulb_outline,
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFFFA025),
                            const Color(0xFFFFA025).withOpacity(0.8),
                          ],
                        ),
                        title: 'Health Tips',
                        subtitle: 'Personalized recommendations',
                        onTap: () {},
                      ),

                      const SizedBox(height: 28),

                      // Recent Activity Section
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFA025).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.schedule,
                              color: Color(0xFFFFA025),
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF262A31),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Enhanced Empty State
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 48),
                        decoration: BoxDecoration(
                          color:
                              isDark ? const Color(0xFF1E1E1E) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: isDark
                                  ? Colors.black.withOpacity(0.2)
                                  : Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: blue.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.folder_open,
                                size: 48,
                                color: blue.withOpacity(0.6),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No reports yet',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : const Color(0xFF262A31),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Upload your first lab report to get started',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark
                                    ? Colors.white70
                                    : const Color(0xFF8D95A9),
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.add, size: 20),
                              label: const Text('Add Report'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
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

  Widget _buildEnhancedHealthCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required Color iconColor,
    required Color bgColor,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.2)
                : Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : const Color(0xFF262A31),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedQuickAction({
    required IconData icon,
    required Gradient gradient,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white.withOpacity(0.8),
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

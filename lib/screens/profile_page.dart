import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/backend_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final ValueNotifier<ThemeMode> themeNotifier;

  const ProfilePage({super.key, required this.themeNotifier});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  bool pushNotificationsEnabled = true;
  bool biometricLogin = false;
  final AuthService _authService = AuthService();

  String? userName;
  String? userEmail;
  bool _isLoading = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadCachedUserProfile().then((_) => _loadUserProfile());

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

  Future<void> _loadCachedUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedName = prefs.getString('userName');
    final cachedEmail = prefs.getString('userEmail');
    if (cachedName != null || cachedEmail != null) {
      setState(() {
        userName = cachedName ?? userName;
        userEmail = cachedEmail ?? userEmail;
      });
    }
  }

  Future<void> _loadUserProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final user = _authService.getCurrentUser();
      if (user == null) {
        throw Exception('No logged-in user');
      }

      final token = await user.getIdToken(true);
      final profile = await BackendService(
              baseUrl: "https://healthmatex-backend.onrender.com")
          .getUserProfile(uid: user.uid, firebaseIdToken: token!);

      setState(() {
        userName = profile['name'];
        userEmail = profile['email'];
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userName', userName ?? '');
      await prefs.setString('userEmail', userEmail ?? '');
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user profile';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    final blue = const Color(0xFF2684FF);

    Color tileBg = isDark ? const Color(0xFF232A35) : Colors.white;
    Color sectionLabel = isDark ? Colors.grey[400]! : const Color(0xFF9DA6B6);

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor:
            isDark ? const Color(0xFF13161A) : const Color(0xFFF7F8FA),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Enhanced Header with Gradient
                Container(
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          blue,
                          blue.withOpacity(0.85),
                        ],
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
                        children: [
                          // Profile Avatar
                          Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 3,
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 50,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.2),
                                  child: Text(
                                    _getInitials(userName ?? "U"),
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: blue,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // User Info
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            )
                          else ...[
                            Text(
                              userName ?? "Loading...",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              userEmail ?? "Loading email...",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.85),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Edit Profile Button
                            ElevatedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text("Edit Profile"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white.withOpacity(0.2),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 10,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ACCOUNT Section
                _SectionHeader(
                  icon: Icons.person_outline,
                  label: "ACCOUNT",
                  color: sectionLabel,
                ),
                _EnhancedSettingTile(
                  icon: Icons.person_outline,
                  title: "Personal Information",
                  subtitle: "Update your details",
                  iconColor: const Color(0xFF2684FF),
                  iconBg: const Color(0xFF2684FF).withOpacity(0.1),
                  onTap: () {},
                  bgColor: tileBg,
                ),
                _EnhancedSettingTile(
                  icon: Icons.shield_outlined,
                  title: "Privacy & Security",
                  subtitle: "Manage your privacy",
                  iconColor: const Color(0xFF7357DA),
                  iconBg: const Color(0xFF7357DA).withOpacity(0.1),
                  onTap: () {},
                  bgColor: tileBg,
                ),
                _EnhancedSettingTile(
                  icon: Icons.notifications_outlined,
                  title: "Push Notifications",
                  subtitle: pushNotificationsEnabled ? "Enabled" : "Disabled",
                  iconColor: const Color(0xFFFFA025),
                  iconBg: const Color(0xFFFFA025).withOpacity(0.1),
                  trailing: Switch(
                    activeColor: blue,
                    value: pushNotificationsEnabled,
                    onChanged: (v) => setState(() {
                      pushNotificationsEnabled = v;
                    }),
                  ),
                  bgColor: tileBg,
                ),

                const SizedBox(height: 20),

                // HEALTH DATA Section
                _SectionHeader(
                  icon: Icons.favorite_outline,
                  label: "HEALTH DATA",
                  color: sectionLabel,
                ),
                _EnhancedSettingTile(
                  icon: Icons.favorite_outline,
                  title: "Health Preferences",
                  subtitle: "Set your health goals",
                  iconColor: const Color(0xFFFF6B6B),
                  iconBg: const Color(0xFFFF6B6B).withOpacity(0.1),
                  onTap: () {},
                  bgColor: tileBg,
                ),
                _EnhancedSettingTile(
                  icon: Icons.download_outlined,
                  title: "Export Data",
                  subtitle: "Download your reports",
                  iconColor: const Color(0xFF24CB59),
                  iconBg: const Color(0xFF24CB59).withOpacity(0.1),
                  onTap: () {},
                  bgColor: tileBg,
                ),
                _EnhancedSettingTile(
                  icon: Icons.sync,
                  title: "Sync with HealthKit",
                  subtitle: "Connect your data",
                  iconColor: const Color(0xFF52C4A2),
                  iconBg: const Color(0xFF52C4A2).withOpacity(0.1),
                  onTap: () {},
                  bgColor: tileBg,
                ),

                const SizedBox(height: 20),

                // APP SETTINGS Section
                _SectionHeader(
                  icon: Icons.settings_outlined,
                  label: "APP SETTINGS",
                  color: sectionLabel,
                ),
                _EnhancedSettingTile(
                  icon: Icons.fingerprint,
                  title: "Biometric Login",
                  subtitle: biometricLogin ? "Enabled" : "Disabled",
                  iconColor: const Color(0xFF57C1F3),
                  iconBg: const Color(0xFF57C1F3).withOpacity(0.1),
                  trailing: Switch(
                    activeColor: blue,
                    value: biometricLogin,
                    onChanged: (v) => setState(() {
                      biometricLogin = v;
                    }),
                  ),
                  bgColor: tileBg,
                ),
                _EnhancedSettingTile(
                  icon: Icons.dark_mode_outlined,
                  title: "Dark Mode",
                  subtitle: widget.themeNotifier.value == ThemeMode.dark
                      ? "Dark theme active"
                      : "Light theme active",
                  iconColor: const Color(0xFF9B59B6),
                  iconBg: const Color(0xFF9B59B6).withOpacity(0.1),
                  trailing: Switch(
                    activeColor: blue,
                    value: widget.themeNotifier.value == ThemeMode.dark,
                    onChanged: (v) {
                      widget.themeNotifier.value =
                          v ? ThemeMode.dark : ThemeMode.light;
                    },
                  ),
                  bgColor: tileBg,
                ),
                _EnhancedSettingTile(
                  icon: Icons.language_rounded,
                  title: "Language",
                  subtitle: "English (US)",
                  iconColor: const Color(0xFFFFAC41),
                  iconBg: const Color(0xFFFFAC41).withOpacity(0.1),
                  trailing: Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
                  onTap: () {},
                  bgColor: tileBg,
                ),

                const SizedBox(height: 20),

                // SUPPORT Section
                _SectionHeader(
                  icon: Icons.help_outline,
                  label: "SUPPORT",
                  color: sectionLabel,
                ),
                _EnhancedSettingTile(
                  icon: Icons.help_outline,
                  title: "Help & FAQ",
                  subtitle: "Get answers",
                  iconColor: const Color(0xFF3498DB),
                  iconBg: const Color(0xFF3498DB).withOpacity(0.1),
                  onTap: () {},
                  bgColor: tileBg,
                ),
                _EnhancedSettingTile(
                  icon: Icons.chat_outlined,
                  title: "Contact Support",
                  subtitle: "We're here to help",
                  iconColor: const Color(0xFF16A085),
                  iconBg: const Color(0xFF16A085).withOpacity(0.1),
                  onTap: () {},
                  bgColor: tileBg,
                ),
                _EnhancedSettingTile(
                  icon: Icons.info_outline,
                  title: "About",
                  subtitle: "Version 1.0.0",
                  iconColor: const Color(0xFF95A5A6),
                  iconBg: const Color(0xFF95A5A6).withOpacity(0.1),
                  onTap: () {},
                  bgColor: tileBg,
                ),

                const SizedBox(height: 24),

                // SIGN OUT BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          title: const Text("Sign Out"),
                          content: const Text(
                            "Are you sure you want to sign out?",
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx, false),
                              child: const Text("Cancel"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(ctx, true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("Sign Out"),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                        await _authService.signOut();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Signed out successfully'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                          Navigator.pushNamedAndRemoveUntil(
                              context, '/login', (route) => false);
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.red.shade400,
                            Colors.red.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.logout, color: Colors.white, size: 20),
                          SizedBox(width: 10),
                          Text(
                            "Sign Out",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Center(
                  child: Text(
                    "HealthMateX v1.0.0",
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isDark ? Colors.grey[600] : const Color(0xFFB0B4C6),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}

// Enhanced Section Header
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// Enhanced Setting Tile
class _EnhancedSettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final Color iconBg;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color bgColor;

  const _EnhancedSettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconBg,
    this.trailing,
    this.onTap,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[400],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

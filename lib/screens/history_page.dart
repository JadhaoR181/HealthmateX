import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage>
    with SingleTickerProviderStateMixin {
  int filterIndex = 0;
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
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
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Dummy reports data structure
  final List<Map<String, dynamic>> reports = [
    {
      "title": "Complete Blood Test",
      "date": DateTime(2024, 1, 15),
      "score": 75,
      "risk": "Low Risk",
      "riskColor": Color(0xFF24CB59),
      "riskBg": Color(0xFFEAF9F0),
      "conditions": 3
    },
    {
      "title": "Lipid Profile",
      "date": DateTime(2024, 1, 1),
      "score": 68,
      "risk": "Moderate Risk",
      "riskColor": Color(0xFFFFA025),
      "riskBg": Color(0xFFFFF4E5),
      "conditions": 5
    },
    {
      "title": "Diabetes Panel",
      "date": DateTime(2023, 12, 15),
      "score": 85,
      "risk": "Low Risk",
      "riskColor": Color(0xFF24CB59),
      "riskBg": Color(0xFFEAF9F0),
      "conditions": 2
    },
    {
      "title": "Kidney Function Test",
      "date": DateTime(2023, 11, 28),
      "score": 90,
      "risk": "Low Risk",
      "riskColor": Color(0xFF24CB59),
      "riskBg": Color(0xFFEAF9F0),
      "conditions": 4
    },
    {
      "title": "Liver Function Test",
      "date": DateTime(2023, 11, 10),
      "score": 55,
      "risk": "High Risk",
      "riskColor": Color(0xFFFF6B6B),
      "riskBg": Color(0xFFFFE5E5),
      "conditions": 6
    },
  ];

  List<Map<String, dynamic>> get filteredReports {
    List<Map<String, dynamic>> filtered = reports;

    // Filtering logic
    if (filterIndex == 1) {
      filtered = reports
          .where((r) =>
              r['date'].isAfter(DateTime.now().subtract(Duration(days: 30))))
          .toList();
    }
    if (filterIndex == 2) {
      filtered = reports
          .where(
              (r) => r['risk'] == "Moderate Risk" || r['risk'] == "High Risk")
          .toList();
    }

    // Search logic (by title, case insensitive)
    if (searchQuery.isNotEmpty) {
      filtered = filtered
          .where((r) => r['title']
              .toString()
              .toLowerCase()
              .contains(searchQuery.trim().toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF2684FF);

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: FadeTransition(
          opacity: _fadeAnimation,
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.history,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Health History",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 28,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.filter_list,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${reports.length} ${reports.length == 1 ? 'report' : 'reports'} in total",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey[600]),
                    hintText: "Search reports by name...",
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    filled: true,
                    fillColor: Colors.white,
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                searchQuery = "";
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[200]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: blue, width: 2),
                    ),
                  ),
                ),
              ),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip("All Reports", 0, blue, Icons.list_alt),
                      const SizedBox(width: 10),
                      _buildFilterChip("Recent", 1, blue, Icons.access_time),
                      const SizedBox(width: 10),
                      _buildFilterChip(
                          "High Risk", 2, blue, Icons.warning_amber),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Report Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "${filteredReports.length} ${filteredReports.length == 1 ? 'report' : 'reports'} found",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Reports List
              Expanded(
                child: filteredReports.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: filteredReports.length,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 8),
                        itemBuilder: (context, i) {
                          final r = filteredReports[i];
                          return _buildEnhancedReportCard(r, i);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEnhancedReportCard(Map<String, dynamic> report, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Colored left border
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 5,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      report['riskColor'],
                      report['riskColor'].withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Row: Title and Score
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              report['title'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                                color: Color(0xFF262A31),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.calendar_today,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  DateFormat('MMM dd, yyyy')
                                      .format(report['date']),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Score Circle
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: report['riskBg'],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: report['riskColor'].withOpacity(0.3),
                            width: 3,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              report['score'].toString(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: report['riskColor'],
                                fontSize: 24,
                              ),
                            ),
                            Text(
                              "Score",
                              style: TextStyle(
                                fontSize: 11,
                                color: report['riskColor'],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Risk Badge and Conditions
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: report['riskBg'],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: report['riskColor'].withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getRiskIcon(report['risk']),
                              size: 14,
                              color: report['riskColor'],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              report['risk'],
                              style: TextStyle(
                                color: report['riskColor'],
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2684FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.medical_services_outlined,
                              size: 14,
                              color: Color(0xFF2684FF),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${report['conditions']} conditions",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF2684FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Divider
                  Container(
                    height: 1,
                    color: Colors.grey[200],
                  ),

                  const SizedBox(height: 16),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            // View details logic
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2684FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.remove_red_eye_outlined,
                                  color: Color(0xFF2684FF),
                                  size: 18,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  "View Details",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF2684FF),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      InkWell(
                        onTap: () {
                          // Share logic
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2684FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.share,
                            color: Color(0xFF2684FF),
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      InkWell(
                        onTap: () {
                          // Download logic
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2684FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.download,
                            color: Color(0xFF2684FF),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int index, Color blue, IconData icon) {
    final bool selected = filterIndex == index;
    return InkWell(
      onTap: () => setState(() => filterIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? blue : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? blue : Colors.grey[300]!,
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: blue.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF2684FF).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.folder_open,
              size: 64,
              color: const Color(0xFF2684FF).withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "No reports found",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF262A31),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            searchQuery.isNotEmpty
                ? "Try adjusting your search query"
                : "Upload your first report to get started",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to scan page
            },
            icon: const Icon(Icons.add, size: 20),
            label: const Text("Add Report"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2684FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRiskIcon(String risk) {
    switch (risk) {
      case "Low Risk":
        return Icons.check_circle;
      case "Moderate Risk":
        return Icons.warning;
      case "High Risk":
        return Icons.error;
      default:
        return Icons.info;
    }
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../services/report_service.dart';

class ScanReportPage extends StatefulWidget {
  const ScanReportPage({Key? key}) : super(key: key);

  @override
  State<ScanReportPage> createState() => _ScanReportPageState();
}

class _ScanReportPageState extends State<ScanReportPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> reports = [];
  List<Map<String, dynamic>> filteredReports = [];
  bool _isLoading = true;
  String _filterText = '';
  String _selectedFilter = 'All';

  final ReportService _reportService = ReportService();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _filterController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _loadReportsFromMongoDB();
    _filterController.addListener(_filterReports);

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
    _filterController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _filterReports() {
    setState(() {
      _filterText = _filterController.text.toLowerCase();
      filteredReports = reports.where((report) {
        final matchesSearch =
            report['name'].toLowerCase().contains(_filterText);

        if (_selectedFilter == 'All') return matchesSearch;

        final uploadDate = report['upload_date'] as DateTime;
        final now = DateTime.now();

        switch (_selectedFilter) {
          case 'Today':
            return matchesSearch &&
                uploadDate.year == now.year &&
                uploadDate.month == now.month &&
                uploadDate.day == now.day;
          case 'This Week':
            final weekAgo = now.subtract(const Duration(days: 7));
            return matchesSearch && uploadDate.isAfter(weekAgo);
          case 'This Month':
            return matchesSearch &&
                uploadDate.year == now.year &&
                uploadDate.month == now.month;
          default:
            return matchesSearch;
        }
      }).toList();
    });
  }

  Future<void> _loadReportsFromMongoDB() async {
    setState(() => _isLoading = true);

    try {
      final loadedReports = await _reportService.loadReports();

      reports = loadedReports.map((report) {
        return {
          'id': report['id'],
          'name': report['name'],
          's3_url': report['s3_url'],
          'file_key': report['file_key'], // ✅ Add this line
          'upload_date': report['upload_date'],
        };
      }).toList();
    } catch (e) {
      print('Error loading reports: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load reports: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
      _filterReports();
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile =
        await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (pickedFile != null) {
      _showReportFormDialog(File(pickedFile.path));
    }
  }

  Future<void> _showReportFormDialog(File imageFile) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final titleController = TextEditingController();
    final captureTime = DateTime.now();

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2684FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.description_outlined,
                        color: Color(0xFF2684FF),
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "New Lab Report",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: const Icon(Icons.close),
                      color: Colors.grey,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Image Preview
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[300]!, width: 2),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title Field
                Text(
                  "Report Title",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: InputDecoration(
                    hintText: "e.g., Blood Test Report",
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFF2684FF),
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Timestamp Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2684FF).withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2684FF).withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2684FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.access_time,
                          color: Color(0xFF2684FF),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Captured At",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            DateFormat('MMM dd, yyyy • hh:mm a')
                                .format(captureTime),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey[400]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (titleController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please enter a report title'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          Navigator.of(ctx).pop();

                          // Show loading
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (ctx) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );

                          final user = _auth.currentUser;
                          if (user == null) return;

                          try {
                            await _reportService.uploadReportToS3(
                              imageFile: imageFile,
                              reportName: titleController.text,
                            );

                            Navigator.of(context).pop(); // Close loading
                            _loadReportsFromMongoDB();

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    const Text('Report uploaded successfully!'),
                                backgroundColor: Colors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          } catch (e) {
                            Navigator.of(context).pop(); // Close loading

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Upload failed: $e'),
                                backgroundColor: Colors.red,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            );
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text('Report saved successfully!'),
                              backgroundColor: Colors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF2684FF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Save Report",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReportImage(String? fileKey) {
    if (fileKey == null || fileKey.isEmpty) {
      return Container(
        width: 80,
        height: 80,
        color: Colors.grey[200],
        child:
            const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
      );
    }

    return FutureBuilder<String?>(
      future: _reportService.getPresignedViewUrl(fileKey),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child: const Icon(Icons.broken_image, size: 40, color: Colors.grey),
          );
        }

        return Image.network(
          snapshot.data!,
          width: 80,
          height: 80,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                      : null,
                  strokeWidth: 2,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Error loading image: $error');
            return Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child:
                  const Icon(Icons.broken_image, size: 40, color: Colors.grey),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final blue = const Color(0xFF2684FF);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? Color(0xFF121212) : Color(0xFFF7F8FA);

    return SafeArea(
      top: false,
      child: Scaffold(
        backgroundColor: backgroundColor,
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
                                Icons.assignment,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                "Lab Reports",
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
                                Icons.upload_file,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Manage your medical documents",
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

              // Action Buttons
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickImage(ImageSource.camera),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [blue, blue.withOpacity(0.8)],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: blue.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.camera_alt,
                                  color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Camera",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: InkWell(
                        onTap: () => _pickImage(ImageSource.gallery),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? Color(0xFF1E1E1E) : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: isDark
                                    ? Colors.black.withOpacity(0.5)
                                    : Colors.black.withOpacity(0.06),
                                blurRadius: 15,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library, color: blue, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Gallery",
                                style: TextStyle(
                                  color: blue,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  controller: _filterController,
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87, // Text color
                  ),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      Icons.search,
                      color: isDark
                          ? Colors.white70
                          : Colors.grey[600], // Icon color
                    ),
                    hintText: "Search by report name...",
                    hintStyle: TextStyle(
                      color: isDark
                          ? Colors.white54
                          : Colors.grey[400], // Hint color
                    ),
                    filled: true,
                    fillColor: isDark
                        ? Colors.grey[850]
                        : Colors.grey[200], // Background color
                    suffixIcon: _filterText.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear,
                                size: 20,
                                color:
                                    isDark ? Colors.white70 : Colors.grey[600]),
                            onPressed: () {
                              _filterController.clear();
                              setState(() {
                                _filterText = '';
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
                      borderSide: BorderSide(
                        color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: blue,
                        width: 2,
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _filterText = value;
                      _filterReports(); // call your filter function
                    });
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Filter Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Today', 'This Week', 'This Month']
                        .map((filter) {
                      final isSelected = _selectedFilter == filter;

                      final chipBackgroundColor = isSelected
                          ? blue
                          : isDark
                              ? Color(0xFF2C2C2C) // dark mode background
                              : Colors.white; // light mode background

                      final chipBorderColor = isSelected
                          ? blue
                          : isDark
                              ? Colors.grey[700]!
                              : Colors.grey[300]!;

                      final chipTextColor = isSelected
                          ? Colors.white
                          : isDark
                              ? Colors.white70
                              : Colors.black87;

                      final List<BoxShadow> chipBoxShadow = isSelected
                          ? [
                              BoxShadow(
                                color: blue.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : [];

                      return Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              _selectedFilter = filter;
                              _filterReports();
                            });
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              color: chipBackgroundColor,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: chipBorderColor,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: chipBoxShadow,
                            ),
                            child: Text(
                              filter,
                              style: TextStyle(
                                color: chipTextColor,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Report Count
              if (!_isLoading)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    "${filteredReports.length} ${filteredReports.length == 1 ? 'report' : 'reports'} found",
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? Colors.white : Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              const SizedBox(height: 12),

              // Report List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filteredReports.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: blue.withOpacity(0.1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.folder_open,
                                    size: 64,
                                    color: blue.withOpacity(0.6),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  _filterText.isEmpty &&
                                          _selectedFilter == 'All'
                                      ? "No reports yet"
                                      : "No matching reports",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _filterText.isEmpty &&
                                          _selectedFilter == 'All'
                                      ? "Upload your first lab report to get started"
                                      : "Try adjusting your search or filter",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white
                                        : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredReports.length,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemBuilder: (ctx, index) {
                              final report = filteredReports[index];
                              final uploadDate =
                                  report['upload_date'] as DateTime;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Color(0xFF1E1E1E)
                                      : const Color.fromRGBO(255, 255, 255, 1),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: isDark
                                          ? Colors.black.withOpacity(0.5)
                                          : Colors.black.withOpacity(0.06),
                                      blurRadius: 15,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(16),
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child:
                                        _buildReportImage(report['file_key']),
                                  ),
                                  title: Text(
                                    report['name'],
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                  subtitle: Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.calendar_today,
                                          size: 14,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          DateFormat('MMM dd, yyyy')
                                              .format(uploadDate),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Icon(
                                          Icons.access_time,
                                          size: 14,
                                          color: Colors.grey[500],
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          DateFormat('hh:mm a')
                                              .format(uploadDate),
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: isDark
                                                ? Colors.white
                                                : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  trailing: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: blue.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.more_vert,
                                      color: blue,
                                      size: 20,
                                    ),
                                  ),
                                  onTap: () {
                                    // Handle report tap
                                  },
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

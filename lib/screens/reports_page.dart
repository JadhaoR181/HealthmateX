import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List<Map<String, dynamic>> reports = [];

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  // Load saved reports from SharedPreferences
  Future<void> _loadReports() async {
    final prefs = await SharedPreferences.getInstance();
    final savedReports = prefs.getStringList('reports') ?? [];
    setState(() {
      reports = savedReports
          .map((r) => json.decode(r))
          .toList()
          .cast<Map<String, dynamic>>();
    });
  }

  // Save reports
  Future<void> _saveReports() async {
    final prefs = await SharedPreferences.getInstance();
    final reportStrings = reports.map((r) => json.encode(r)).toList();
    await prefs.setStringList('reports', reportStrings);
  }

  // Add a new report
  Future<void> _addReportDialog() async {
    final nameController = TextEditingController();
    final notesController = TextEditingController();
    String? category;
    File? capturedImage;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
              top: 20,
              left: 20,
              right: 20),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              Future<void> captureImage() async {
                final pickedFile =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setModalState(() {
                    capturedImage = File(pickedFile.path);
                  });
                }
              }

              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Add New Report",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: "Report Name",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                      value: category,
                      items: ["Blood Test", "X-Ray", "MRI", "Prescription"]
                          .map((cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)))
                          .toList(),
                      onChanged: (val) {
                        setModalState(() {
                          category = val;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: notesController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: "Notes (Optional)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    capturedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(capturedImage!,
                                height: 120,
                                width: double.infinity,
                                fit: BoxFit.cover),
                          )
                        : OutlinedButton.icon(
                            onPressed: captureImage,
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Capture Image"),
                          ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty ||
                            capturedImage == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Please fill all required fields")),
                          );
                          return;
                        }

                        final newReport = {
                          "name": nameController.text,
                          "category": category ?? "General",
                          "notes": notesController.text,
                          "imagePath": capturedImage!.path,
                          "timestamp": DateTime.now().toString(),
                        };

                        setState(() {
                          reports.add(newReport);
                        });
                        _saveReports();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text("Save Report"),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  // UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: reports.isEmpty
          ? const Center(child: Text("No reports yet. Tap + to add one."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 2,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(report["imagePath"]),
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(report["name"],
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                        "${report["category"]} • ${report["timestamp"].substring(0, 16)}\n${report["notes"] ?? ""}"),
                    isThreeLine: true,
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReportDialog,
        backgroundColor: Colors.white,
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ),
    );
  }
}

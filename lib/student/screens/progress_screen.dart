import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressScreen extends StatefulWidget {
  final String projectId;
  final int totalWeeks;

  const ProgressScreen({
    super.key,
    required this.projectId,
    required this.totalWeeks,
  });

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  int? selectedWeek;
  final taskController = TextEditingController();

  Future<void> addProgress() async {
    if (selectedWeek == null || taskController.text.isEmpty) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('progress')
        .where('projectId', isEqualTo: widget.projectId)
        .get();

    bool exists = snapshot.docs.any(
      (d) => d['week'] == selectedWeek.toString(),
    );

    if (exists) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Week already added")));
      return;
    }

    if (snapshot.docs.length >= widget.totalWeeks) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Project completed")));
      return;
    }

    await FirebaseFirestore.instance.collection('progress').add({
      'projectId': widget.projectId,
      'week': selectedWeek.toString(),
      'task': taskController.text.trim(),
      'date': FieldValue.serverTimestamp(),
    });

    setState(() => selectedWeek = null);
    taskController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),

      /// APP BAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Progress Tracking",
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// WEEK DROPDOWN
            Text(
              "Select Week",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color.fromARGB(221, 123, 123, 123),
              ),
            ),
            const SizedBox(height: 6),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('progress')
                  .where('projectId', isEqualTo: widget.projectId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const LinearProgressIndicator();
                }

                final docs = snapshot.data!.docs;
                List<int> usedWeeks = docs
                    .map((d) => int.parse(d['week']))
                    .toList();

                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F3F6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: selectedWeek,
                      isExpanded: true,
                      hint: Text(
                        "Week (1 - ${widget.totalWeeks})",
                        style: GoogleFonts.poppins(fontSize: 12),
                      ),
                      items: List.generate(widget.totalWeeks, (index) {
                        int week = index + 1;
                        bool isUsed = usedWeeks.contains(week);

                        return DropdownMenuItem<int>(
                          value: isUsed ? null : week,
                          enabled: !isUsed,
                          child: Text(
                            "Week $week",
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: isUsed ? Colors.grey : Colors.black,
                              decoration: isUsed
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        );
                      }),
                      onChanged: (v) {
                        if (v != null) {
                          setState(() => selectedWeek = v);
                        }
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            /// TASK INPUT
            Text(
              "Task",
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: const Color.fromARGB(221, 123, 123, 123),
              ),
            ),
            const SizedBox(height: 6),

            TextField(
              controller: taskController,
              decoration: InputDecoration(
                hintText: "Enter task details",
                hintStyle: const TextStyle(fontSize: 12),
                filled: true,
                fillColor: const Color(0xFFF1F3F6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 15),

            /// ADD BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: addProgress,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Add Progress",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// LIST TITLE
            Text(
              "Progress Timeline",
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 10),

            /// LIST
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('progress')
                    .where('projectId', isEqualTo: widget.projectId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return Center(
                      child: Text(
                        "No progress yet",
                        style: GoogleFonts.poppins(color: Colors.black54),
                      ),
                    );
                  }

                  docs.sort(
                    (a, b) =>
                        int.parse(a['week']).compareTo(int.parse(b['week'])),
                  );

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, i) {
                      final d = docs[i];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Row(
                          children: [
                            /// WEEK BADGE
                            Container(
                              height: 36,
                              width: 36,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                d['week'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),

                            const SizedBox(width: 12),

                            /// TEXT
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Week ${d['week']}",
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    d['task'],
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

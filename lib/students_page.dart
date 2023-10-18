import 'package:sqlite4att/sqlbd.dart';
import 'package:flutter/material.dart';
class StudentsPage extends StatefulWidget {
  final int subjectId;

  StudentsPage({required this.subjectId});

  @override
  _StudentsPageState createState() => _StudentsPageState();
}

class _StudentsPageState extends State<StudentsPage> {
  final dbHelper = Sqldb();
  List<Map>? students;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    students = await getStudentsBySubject(widget.subjectId);
    setState(() {});
  }

  Future<List<Map>> getStudentsBySubject(int subjectId) async {
    String sqlQuery = '''
       SELECT students.id, students.name as student_name, students.faculty, students.department, students.level
        FROM students
      INNER JOIN subjects 
      ON students.faculty = subjects.faculty
      AND students.department = subjects.department
      AND students.level = subjects.level
      WHERE subjects.id = ?
    ''';

    List<Map> results = await dbHelper.readDataWithArguments(
        sqlQuery, [subjectId]);
    print('Results: $results');
    return results;
  }

  void storeAttendanceData(int studentId, int subjectId, int attendances) async {
    Map<String, dynamic> attendanceData = {
      'student_id': studentId,
      'subject_id': subjectId,
      'attendances': attendances
    };
    await dbHelper.insertAttendance(attendanceData);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: attendances == 1 ? Text('Student marked as present') : Text(
      'Student marked as absent')));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Preparing students'),
      backgroundColor:Colors.greenAccent ),
      body: students != null ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Student name: ${students![currentIndex]['student_name']}',
              style: TextStyle(fontSize: 24),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    storeAttendanceData(
                        students![currentIndex]['id'], widget.subjectId, 1);
                    setState(() {
                      currentIndex = (currentIndex + 1) % students!.length;
                    });
                  },
                  child: Text('✅'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () {
                    storeAttendanceData(
                        students![currentIndex]['id'], widget.subjectId, 0);
                    setState(() {
                      currentIndex = (currentIndex + 1) % students!.length;
                    });
                  },
                  child: Text('❌'),
                ),
              ],
            ),
          ],
        ),
      ) : CircularProgressIndicator(),
    );
  }
}
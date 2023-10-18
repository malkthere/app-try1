 import 'package:flutter/material.dart';
 import 'sqlbd.dart';
 import 'students_page.dart';
class TeacherSubjectsPage extends StatefulWidget {
 const TeacherSubjectsPage({Key? key}) : super(key: key);
@override
_TeacherSubjectsPageState createState() => _TeacherSubjectsPageState();
}

 class _TeacherSubjectsPageState extends State<TeacherSubjectsPage> {
  final dbHelper = Sqldb();
  String? _teacherName;
  List<Map<String, dynamic>>? _subjects;
  String? _selectedSubjectId;
  TextEditingController _nameController = TextEditingController();
  @override
  Widget build(BuildContext context) {
   return Scaffold(
    appBar: AppBar(
     title: Text("Teacher Subjects"),
        backgroundColor:Colors.greenAccent
    ),
    body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
         Padding(
          padding: EdgeInsets.all(16.0),
          child: TextField(
           controller: _nameController,
           decoration:
           InputDecoration(
               labelText: "Teacher Name", border: OutlineInputBorder()),
           onChanged: (value) async {
            setState(() {
             _teacherName = value;
            });
            int? teacherId = await dbHelper.getTeacherIdByName(_teacherName!);
            if (teacherId != null) {
             List<Map<String, dynamic>> subjects =
             await dbHelper.getSubjectsByTeacherId(teacherId);
             print('Subjects: $subjects');
             setState(() {
              _subjects = subjects;
             });
            } else {
             setState(() {
              _subjects = null;
             });
            }
           },
          ),
         ),
         _subjects != null && _subjects!.isNotEmpty
             ? DropdownButton<String>(
          hint: Text("Select a subject"),
          value: _selectedSubjectId,
          onChanged: (String? newValue) {
           setState(() {
            _selectedSubjectId = newValue;
           });
          },
          items: _subjects!
              .map<DropdownMenuItem<String>>((
              Map<String, dynamic> subjectData) {
           return DropdownMenuItem<String>(
            value: subjectData['id'].toString(),
            child: Text(subjectData['name'].toString()),
           );
          }).toList(),
         )
             : CircularProgressIndicator(),
         SizedBox(height: 16),
         TextButton(
          onPressed: _selectedSubjectId != null
              ? () {
           int subjectId = int.parse(_selectedSubjectId!);
           Navigator.push(
            context,
            MaterialPageRoute(
             builder: (context) => StudentsPage(subjectId: subjectId),
            ),
           );
          }
              : null,
          child: Text("OK"),
         ),
        ]),
   );
  }
 }
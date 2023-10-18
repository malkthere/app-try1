import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class Sqldb {
  intialDb()async{
    String databasepath =await getDatabasesPath();
    String path =join (databasepath,'schools.db');
    Database mydb= await openDatabase(path,onCreate:_onCreate, version: 1, onUpgrade: _onUpgrabe  );
    return mydb;
  }
  _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE students (
        "id" INTEGER PRIMARY KEY AUTOINCREMENT,
        "name" TEXT NOT NULL,
        "department" TEXT NOT NULL,
        "faculty" TEXT NOT NULL,
       "level" INTEGER NOT NULL
      )
      ''');

    await db.execute('''
      CREATE TABLE subjects (
        "id" INTEGER PRIMARY KEY AUTOINCREMENT,
        "name" TEXT NOT NULL,
        "department" TEXT NOT NULL,
        "faculty" TEXT NOT NULL,
       "level" INTEGER NOT NULL,
        "teacher_id" INTEGER,
        FOREIGN KEY ("teacher_id") REFERENCES "teacher" ("id"));
      )
      ''');
    await db.execute('''
      CREATE TABLE attendance (
        "id" INTEGER PRIMARY KEY AUTOINCREMENT,
        "student_id" INTEGER NOT NULL,
        "subject_id" INTEGER NOT NULL,
        "attendances" INTEGER  NOT NULL,
        FOREIGN KEY (student_id) REFERENCES students (id),
        FOREIGN KEY (subject_id) REFERENCES subjects (id)
      )
      ''');
    await db.execute('''
    CREATE TABLE teacher(
     "id" INTEGER  NOT NULL PRIMARY KEY AUTOINCREMENT,
    "name" TEXT NOT NULL)''');
    List<Map<String, dynamic>> subjects = [
      {
        'name': 'JAVA',
        'department': 'IT',
        'faculty': 'Science',
        'level': 1,
        'teacher_id': 2
      },
      {
        'name': 'C++',
        'department': 'IT',
        'faculty': 'Science',
        'level': 1,
        'teacher_id': 2
      },
      {
        'name': 'DB1',
        'department': 'IT',
        'faculty': 'Science',
        'level': 1,
        'teacher_id': 1
      },
      {
        'name': 'DB2',
        'department': 'CS',
        'faculty': 'Science',
        'level': 1,
        'teacher_id': 2
      },
      {
        'name': 'FLUTTER',
        'department': 'CS',
        'faculty': 'Science',
        'level': 1,
        'teacher_id': 1
      },
    ];
    for (var subject in subjects) {
      await db.insert('subjects', subject);
    }

    List<Map<String, dynamic>> students = [
      {
        'name': 'rana',
        'faculty': 'Science',
        'department': 'IT',
        'level': 1
      },
      {

        'name': 'fatima',
        'faculty': 'Science',
        'department': 'IT',
        'level': 1
      },
      {

        'name': 'habo',
        'faculty': 'Science',
        'department': 'IT',
        'level': 1
      },
      {
        'name': 'Hana',
        'faculty': 'Science',
        'department': 'CS',
        'level': 1
      },
      {
        'name': 'Ahmed',
        'faculty': 'Science',
        'department': 'CS',
        'level': 1
      },
    ];
    for (var student in students) {
      await db.insert('students', student);
    }
    List<Map<String, dynamic>> teachers = [
      {'name': 'saida'},
      {'name': 'ali'}
    ];
    for (var teacher in teachers) {
      await db.insert('teacher', teacher);
    }
  }
  Database?_db;
  Future <Database?>get db async{
    if (_db==null){
      _db=await intialDb();
      return(_db);}
    else {
      return (_db);
    }
  }
  _onUpgrabe(Database db, int oldversion, newversion){
  }
  readData (String sql)async{
    Database? mydb=await db;
    List<Map> response=await mydb!.rawQuery((sql));
    return response;
  }
  insertData (String sql ) async {
    Database? mydb=await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }
  updataData (String sql ) async {
    Database? mydb=await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }
  delete (String sql ) async {
    Database? mydb=await db;
    int response = await mydb!.rawDelete(sql);
    return response;
  }
  Future<int> insertSubject(Map<String, dynamic> subject) async {
    Database? mydb = await db;
    int response = await mydb!.insert('subjects', subject);
    return response;
  }

  // استرجاع جميع المواد
  Future<List<Map>> getAllSubjects() async {
    Database? mydb = await db;
    List<Map> subjects = await mydb!.query('subjects');
    return subjects;
  }
  Future<int> insertStudent(Map<String, dynamic> student)async{

    Database? mydb = await db;
    int response = await mydb!.insert('students', student);
    return response;
  }
  Future<int> insertAttendance(Map<String, dynamic> row) async {
    Database? db = await  _db;
    return await db!.insert('attendance', row);
  }

  Future<List<Map<String, dynamic>>> readDataWithArguments(String query, List<dynamic> arguments) async {
    final dbInstance = await db;
    if (dbInstance != null) {
      return await dbInstance.rawQuery(query, arguments);
    } else {
      print("Database is null.");
      return [];
    }
  }
  Future<List<Map<String, dynamic>>> getStudentsByDepartment(String department) async {
    String query = "SELECT * FROM students WHERE department = ?";
    List<dynamic> args = [department];

    List<Map<String, dynamic>> results = await readDataWithArguments(query, args);
    return results;
  }
  Future<int?> getTeacherIdByName(String name) async {
    Database? db1 = await db;
    if (db1 == null) {
      return null;
    }
   final List<Map<String, dynamic>> results = await db1.query(
  'teacher',
    columns: ['id'],
    where: 'name = ?',
    whereArgs: [name],
    );

    if (results.isEmpty) {
    return null;
    } else {
    return results.first['id'] as int?;
    }
  }
  Future<List<String>> getTeacherSubjects(int teacherId) async {
     Database? db2 = await db;
    if (db2 == null) {
      throw Exception('Database not found');
  }

    final List<Map<String, dynamic>> result = await db2.query(
      'subjects',
      where: 'teacher_id = ?',
      whereArgs: [teacherId],
    );
    final List<String> subjects = result.map((subjectData) => subjectData['name'].toString()).toList();
    return subjects;
  }
  Future<List<Map<String, dynamic>>> getSubjectsByTeacherId(int teacherId) async {
    Database? db3 = await db;
   if (db3 == null) {
    throw Exception('Database not found');
    }
    return await db3.query(
    'subjects',
    where: 'teacher_id = ?',
    whereArgs: [teacherId],
    );
  }
}
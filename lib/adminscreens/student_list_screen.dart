import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../models/student.dart';
import '../utils/database_helper.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class StudentListScreen extends StatefulWidget {
  const StudentListScreen({super.key});

  @override
  State<StudentListScreen> createState() => _StudentListScreenState();
}

class _StudentListScreenState extends State<StudentListScreen> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  String searchQuery = '';
  String selectedClass = 'All';
  String selectedSection = 'All';
  bool showOnlyPresent = false;
  List<Student> students = [];
  bool isLoading = true;
  List<Student> _filteredStudents = [];

  final List<String> classList = ['VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII'];
  final List<String> sectionList = ['A', 'B', 'C'];

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    try {
      final loadedStudents = await _dbHelper.searchStudents(
        query: searchQuery.isEmpty ? null : searchQuery,
        studentClass: selectedClass == 'All' ? null : selectedClass,
        section: selectedSection == 'All' ? null : selectedSection,
        presentOnly: showOnlyPresent,
      );
      if (mounted) {
        setState(() {
          students = loadedStudents;
          _filterStudents();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load students: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showAddEditStudentDialog([Student? student]) async {
    final isEditing = student != null;
    final idController = TextEditingController(text: student?.id);
    final nameController = TextEditingController(text: student?.name);
    final classController =
        TextEditingController(text: student?.studentClass ?? classList[0]);
    final sectionController =
        TextEditingController(text: student?.section ?? sectionList[0]);
    final rollController = TextEditingController(text: student?.roll);
    final parentController = TextEditingController(text: student?.parent);
    final phoneController = TextEditingController(text: student?.phone);
    final addressController = TextEditingController(text: student?.address);
    final busRouteController = TextEditingController(text: student?.busRoute);

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Student' : 'Add New Student'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isEditing)
                TextField(
                  controller: idController,
                  decoration: const InputDecoration(
                    labelText: 'Student ID*',
                    hintText: 'Enter unique ID',
                  ),
                ),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name*',
                  hintText: 'Enter full name',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              DropdownButtonFormField<String>(
                value: classController.text.isEmpty
                    ? classList[0]
                    : classController.text,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    classController.text = newValue;
                  }
                },
                decoration: const InputDecoration(labelText: 'Class*'),
                items: classList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              DropdownButtonFormField<String>(
                value: sectionController.text.isEmpty
                    ? sectionList[0]
                    : sectionController.text,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    sectionController.text = newValue;
                  }
                },
                decoration: const InputDecoration(labelText: 'Section*'),
                items: sectionList.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              TextField(
                controller: rollController,
                decoration: const InputDecoration(
                  labelText: 'Roll Number*',
                  hintText: 'Enter roll number',
                ),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: parentController,
                decoration: const InputDecoration(
                  labelText: 'Parent Name*',
                  hintText: 'Enter parent name',
                ),
                textCapitalization: TextCapitalization.words,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number*',
                  hintText: 'Enter 11-digit phone number',
                ),
                keyboardType: TextInputType.phone,
                maxLength: 11,
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Address*',
                  hintText: 'Enter full address',
                ),
                maxLines: 2,
              ),
              TextField(
                controller: busRouteController,
                decoration: const InputDecoration(
                  labelText: 'Bus Route',
                  hintText: 'Optional: Enter bus route',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              // Validate required fields
              if (nameController.text.isEmpty ||
                  classController.text.isEmpty ||
                  sectionController.text.isEmpty ||
                  rollController.text.isEmpty ||
                  parentController.text.isEmpty ||
                  phoneController.text.isEmpty ||
                  addressController.text.isEmpty ||
                  (!isEditing && idController.text.isEmpty)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Please fill all required fields (marked with *)'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Validate phone number
              if (phoneController.text.length != 11 ||
                  !RegExp(r'^\d+$').hasMatch(phoneController.text)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid 11-digit phone number'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                final newStudent = Student(
                  id: isEditing ? student.id : idController.text,
                  name: nameController.text.trim(),
                  studentClass: classController.text,
                  section: sectionController.text,
                  roll: rollController.text,
                  parent: parentController.text.trim(),
                  phone: phoneController.text,
                  address: addressController.text.trim(),
                  busRoute: busRouteController.text.trim(),
                  attendancePercentage: student?.attendancePercentage ?? 0.0,
                  lastAttendance: student?.lastAttendance,
                  isPresent: student?.isPresent ?? false,
                );

                if (isEditing) {
                  await _dbHelper.updateStudent(newStudent);
                } else {
                  // Check if student ID already exists
                  final exists =
                      await _dbHelper.checkStudentExists(newStudent.id);
                  if (exists) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Student ID already exists'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                    return;
                  }
                  await _dbHelper.insertStudent(newStudent);
                }

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          isEditing ? 'Student updated' : 'Student added'),
                      backgroundColor: Colors.green,
                    ),
                  );
                  Navigator.pop(context, true);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text(isEditing ? 'Save Changes' : 'Add Student'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      await _loadStudents();
    }
  }

  Future<void> _showStudentDetails(Student student) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(student.name),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('ID', student.id),
              _buildDetailRow('Class', student.studentClass),
              _buildDetailRow('Section', student.section),
              _buildDetailRow('Roll', student.roll),
              _buildDetailRow('Parent', student.parent),
              _buildDetailRow('Phone', student.phone),
              _buildDetailRow('Address', student.address),
              _buildDetailRow('Bus Route', student.busRoute ?? 'Not Assigned'),
              _buildDetailRow(
                'Attendance',
                '${student.attendancePercentage.toStringAsFixed(1)}%',
              ),
              if (student.lastAttendance != null)
                _buildDetailRow(
                  'Last Attendance',
                  DateFormat('MMM dd, yyyy').format(student.lastAttendance!),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Edit'),
          ),
        ],
      ),
    );

    if (result == true) {
      _showAddEditStudentDialog(student);
    }
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Future<void> _deleteStudent(Student student) async {
    try {
      await _dbHelper.deleteStudent(student.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Student deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadStudents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting student: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateAttendance(Student student, bool value) async {
    try {
      await _dbHelper.updateAttendance(student.id, value);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value ? 'Marked as present' : 'Marked as absent',
            ),
            backgroundColor: Colors.green,
          ),
        );
        await _loadStudents();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating attendance: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _filterStudents() {
    if (mounted) {
      setState(() {
        if (searchQuery.isEmpty && selectedClass == 'All' && selectedSection == 'All') {
          _filteredStudents = students;
        } else {
          _filteredStudents = students.where((student) {
            final matchesSearch = searchQuery.isEmpty ||
                student.name.toLowerCase().contains(searchQuery.toLowerCase()) ||
                student.id.toLowerCase().contains(searchQuery.toLowerCase()) ||
                student.roll.toLowerCase().contains(searchQuery.toLowerCase());

            final matchesClass = selectedClass == 'All' ||
                student.studentClass == selectedClass;

            final matchesSection = selectedSection == 'All' ||
                student.section == selectedSection;

            return matchesSearch && matchesClass && matchesSection;
          }).toList();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddEditStudentDialog,
            tooltip: 'Add Student',
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                        _filterStudents();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search by name, ID, or roll number',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedClass,
                  items: ['All', 'VI', 'VII', 'VIII', 'IX', 'X', 'XI', 'XII']
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedClass = value;
                        _filterStudents();
                      });
                    }
                  },
                  hint: const Text('Class'),
                ),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: selectedSection,
                  items: ['All', 'A', 'B', 'C']
                      .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        selectedSection = value;
                        _filterStudents();
                      });
                    }
                  },
                  hint: const Text('Section'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _filteredStudents.isEmpty
                ? const Center(
                    child: Text(
                      'No students found',
                      style: TextStyle(fontSize: 16),
                    ),
                  )
                : DataTable2(
                    columns: const [
                      DataColumn2(label: Text('ID'), size: ColumnSize.S),
                      DataColumn2(label: Text('Name'), size: ColumnSize.L),
                      DataColumn2(label: Text('Class'), size: ColumnSize.S),
                      DataColumn2(label: Text('Section'), size: ColumnSize.S),
                      DataColumn2(label: Text('Roll'), size: ColumnSize.S),
                      DataColumn2(label: Text('Attendance'), size: ColumnSize.S),
                      DataColumn2(label: Text('Actions'), size: ColumnSize.M),
                    ],
                    rows: _filteredStudents.map((student) {
                      return DataRow(
                        cells: [
                          DataCell(Text(student.id)),
                          DataCell(
                            Text(student.name),
                            onTap: () => _showStudentDetails(student),
                          ),
                          DataCell(Text(student.studentClass)),
                          DataCell(Text(student.section)),
                          DataCell(Text(student.roll)),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${student.attendancePercentage.toStringAsFixed(1)}%',
                                ),
                                Switch(
                                  value: student.isPresent,
                                  onChanged: (value) =>
                                      _updateAttendance(student, value),
                                ),
                              ],
                            ),
                          ),
                          DataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () =>
                                      _showAddEditStudentDialog(student),
                                  tooltip: 'Edit',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Student'),
                                      content: Text(
                                          'Are you sure you want to delete ${student.name}?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _deleteStudent(student);
                                          },
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  tooltip: 'Delete',
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
          ),
        ],
      ),
    );
  }
}

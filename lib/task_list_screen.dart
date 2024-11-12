import 'package:flutter/material.dart';
import 'auth_service.dart';
import 'task_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final AuthService _authService = AuthService();
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _subTaskController = TextEditingController();
  final TextEditingController _timeFrameController = TextEditingController();
  final CollectionReference _tasks = FirebaseFirestore.instance.collection('tasks');

  String _selectedPriority = 'Medium';
  String _sortOption = 'Priority';
  String _filterPriority = 'All';
  bool _showCompletedTasks = true;

  // Sign out and navigate to login screen
  void _signOut() async {
    await _authService.signOut();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => LoginScreen()));
  }

  // Add a main task
  void _addTask(String name) async {
    await _tasks.add({
      'name': name,
      'isCompleted': false,
      'priority': _selectedPriority,
      'dueDate': DateTime.now().millisecondsSinceEpoch,
      'subTasks': [],
    });
    _taskController.clear();
  }

  // Add a subtask to a specific main task
  void _addSubTask(Task task, String subTaskName, String timeFrame) async {
    final subTask = SubTask(name: subTaskName, timeFrame: timeFrame);
    final updatedSubTasks = List<Map<String, dynamic>>.from(
      task.subTasks.map((subTask) => subTask.toMap()),
    );
    updatedSubTasks.add(subTask.toMap());

    await _tasks.doc(task.id).update({'subTasks': updatedSubTasks});
    _subTaskController.clear();
    _timeFrameController.clear();
  }

  // Toggle completion status of a task
  void _toggleCompletion(Task task) async {
    await _tasks.doc(task.id).update({'isCompleted': !task.isCompleted});
  }

  // Delete a main task
  void _deleteTask(Task task) async {
    await _tasks.doc(task.id).delete();
  }

  // Query to get tasks with sorting and filtering options applied
  Query _getTaskQuery() {
    Query query = _tasks;

    switch (_sortOption) {
      case 'Priority':
        query = query.orderBy('priority');
        break;
      case 'Due Date':
        query = query.orderBy('dueDate');
        break;
      case 'Completion Status':
        query = query.orderBy('isCompleted');
        break;
    }

    if (_filterPriority != 'All') {
      query = query.where('priority', isEqualTo: _filterPriority);
    }

    if (!_showCompletedTasks) {
      query = query.where('isCompleted', isEqualTo: false);
    }

    return query;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Manager'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _signOut,
          ),
          DropdownButton<String>(
            value: _sortOption,
            onChanged: (value) {
              setState(() {
                _sortOption = value!;
              });
            },
            items: ['Priority', 'Due Date', 'Completion Status'].map((sort) {
              return DropdownMenuItem(
                value: sort,
                child: Text(sort),
              );
            }).toList(),
          ),
          DropdownButton<String>(
            value: _filterPriority,
            onChanged: (value) {
              setState(() {
                _filterPriority = value!;
              });
            },
            items: ['All', 'High', 'Medium', 'Low'].map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Text(priority),
              );
            }).toList(),
          ),
          Switch(
            value: _showCompletedTasks,
            onChanged: (value) {
              setState(() {
                _showCompletedTasks = value;
              });
            },
            activeColor: Colors.white,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(labelText: 'Task Name'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_taskController.text.isNotEmpty) {
                      _addTask(_taskController.text);
                    }
                  },
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: _selectedPriority,
            onChanged: (value) {
              setState(() {
                _selectedPriority = value!;
              });
            },
            items: ['High', 'Medium', 'Low'].map((priority) {
              return DropdownMenuItem(
                value: priority,
                child: Text(priority),
              );
            }).toList(),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getTaskQuery().snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                final tasks = snapshot.data!.docs.map((doc) {
                  return Task.fromMap(doc.id, doc.data() as Map<String, dynamic>);
                }).toList();
                return ListView(
                  children: tasks.map((task) => _buildTaskItem(task)).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    Color priorityColor;
    switch (task.priority) {
      case 'High':
        priorityColor = Colors.red;
        break;
      case 'Medium':
        priorityColor = Colors.yellow;
        break;
      case 'Low':
        priorityColor = Colors.green;
        break;
      default:
        priorityColor = Colors.grey;
    }

    return Card(
      color: priorityColor.withOpacity(0.1),
      child: ExpansionTile(
        title: Row(
          children: [
            Checkbox(
              value: task.isCompleted,
              onChanged: (_) => _toggleCompletion(task),
            ),
            Expanded(
              child: Text(task.name, style: TextStyle(color: priorityColor)),
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => _deleteTask(task),
            ),
          ],
        ),
        subtitle: Text('Priority: ${task.priority}'),
        children: [
          ...task.subTasks.map((subTask) => ListTile(
                title: Text(subTask.name),
                subtitle: Text('Time: ${subTask.timeFrame}'),
              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _subTaskController,
                    decoration: InputDecoration(labelText: 'Subtask Name'),
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: _timeFrameController,
                    decoration: InputDecoration(labelText: 'Time Frame (e.g., 9 am - 10 am)'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: () {
                    if (_subTaskController.text.isNotEmpty && _timeFrameController.text.isNotEmpty) {
                      _addSubTask(task, _subTaskController.text, _timeFrameController.text);
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

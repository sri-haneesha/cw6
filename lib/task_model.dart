class Task {
  String id;
  String name;
  bool isCompleted;
  String priority;
  DateTime dueDate;
  List<SubTask> subTasks;

  Task({
    required this.id,
    required this.name,
    this.isCompleted = false,
    this.priority = 'Medium',
    DateTime? dueDate,
    this.subTasks = const [],
  }) : dueDate = dueDate ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'isCompleted': isCompleted,
      'priority': priority,
      'dueDate': dueDate.millisecondsSinceEpoch,
      'subTasks': subTasks.map((subTask) => subTask.toMap()).toList(),
    };
  }

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      name: map['name'],
      isCompleted: map['isCompleted'],
      priority: map['priority'],
      dueDate: DateTime.fromMillisecondsSinceEpoch(map['dueDate']),
      subTasks: (map['subTasks'] as List?)
          ?.map((subTaskMap) => SubTask.fromMap(subTaskMap as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class SubTask {
  String name;
  String timeFrame;

  SubTask({required this.name, required this.timeFrame});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'timeFrame': timeFrame,
    };
  }

  factory SubTask.fromMap(Map<String, dynamic> map) {
    return SubTask(
      name: map['name'],
      timeFrame: map['timeFrame'],
    );
  }
}

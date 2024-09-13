import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'model.dart';
import 'add_task.dart';

class TaskHomePage extends StatefulWidget {
  const TaskHomePage({Key? key}) : super(key: key);

  @override
  _TaskHomePageState createState() => _TaskHomePageState();
}

class _TaskHomePageState extends State<TaskHomePage> {
  final List<Task> tasks = [];
  DateTime selectedDate = DateTime.now();

  String get selectedDateFormatted {
    return DateFormat('EEEE, d MMMM yyyy').format(selectedDate);
  }

  void _showAddTaskBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) => AddTaskBottomSheet(onTaskAdded: _addTask),
    );
  }

  void _addTask(Task task) {
    setState(() {
      tasks.add(task);
    });
  }

  void _toggleTaskCompletion(int taskIndex, int itemIndex) {
    setState(() {
      tasks[taskIndex].items[itemIndex].isCompleted =
          !tasks[taskIndex].items[itemIndex].isCompleted;
    });
  }

  void _toggleTaskExpansion(int taskIndex) {
    setState(() {
      tasks[taskIndex].isExpanded = !tasks[taskIndex].isExpanded;
    });
  }

  void _editTask(int taskIndex, int itemIndex, String newDescription) {
    setState(() {
      tasks[taskIndex].items[itemIndex].text = newDescription;
    });
  }

  void _deleteTask(int taskIndex, int itemIndex) {
    setState(() {
      tasks[taskIndex].items.removeAt(itemIndex);
      if (tasks[taskIndex].items.isEmpty) {
        tasks.removeAt(taskIndex);
      }
    });
  }

  Future<void> _pickTime(BuildContext context, int taskIndex) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
        child: child!,
      ),
    );
    if (picked != null) {
      setState(() {
        tasks[taskIndex].time = picked.format(context);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(toolbarHeight: 0, backgroundColor: Colors.transparent),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 15.0, left: 16.0),
              child: Text('Today',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, bottom: 5.0),
                  child: Text(selectedDateFormatted,
                      style:
                          const TextStyle(color: Colors.grey, fontSize: 15.0)),
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_today, color: Colors.grey),
                  onPressed: () => _selectDate(context),
                ),
              ],
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: tasks.length,
              itemBuilder: (context, index) => TaskListTile(
                task: tasks[index],
                onDelete: (itemIndex) => _deleteTask(index, itemIndex),
                onToggleCompletion: (itemIndex) =>
                    _toggleTaskCompletion(index, itemIndex),
                onToggleExpansion: () => _toggleTaskExpansion(index),
                onEdit: (itemIndex, newDescription) =>
                    _editTask(index, itemIndex, newDescription),
                onPickTime: () => _pickTime(context, index),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(18.0),
        child: SizedBox(
          width: 300.0,
          height: 50.0,
          child: OutlinedButton(
            onPressed: () => _showAddTaskBottomSheet(context),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child:
                const Text('+ Add Task', style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class TaskListTile extends StatelessWidget {
  final Task task;
  final Function(int) onDelete;
  final Function(int) onToggleCompletion;
  final VoidCallback onToggleExpansion;
  final Function(int, String) onEdit;
  final VoidCallback onPickTime;

  const TaskListTile({
    Key? key,
    required this.task,
    required this.onDelete,
    required this.onToggleCompletion,
    required this.onToggleExpansion,
    required this.onEdit,
    required this.onPickTime,
  }) : super(key: key);

  String _getTaskStatusText() {
    final completed = task.items.where((item) => item.isCompleted).length;
    return completed == task.items.length
        ? 'Completed'
        : '$completed/${task.items.length}';
  }

  Color _getTaskStatusColor() {
    final completed = task.items.where((item) => item.isCompleted).length;
    return completed == task.items.length ? Colors.green : Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
              color: const Color.fromARGB(255, 55, 96, 130), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            ListTile(
              title: GestureDetector(
                  onTap: onPickTime,
                  child: Text(task.time,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18))),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getTaskStatusText(),
                      style: TextStyle(color: _getTaskStatusColor())),
                  Icon(task.isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
              onTap: onToggleExpansion,
            ),
            if (task.isExpanded)
              Column(
                children: task.items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final taskItem = entry.value;
                  return Row(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Checkbox(
                              value: taskItem.isCompleted,
                              onChanged: (value) => onToggleCompletion(index),
                              activeColor: Colors.green,
                            ),
                            Expanded(
                              child: Text(taskItem.text,
                                  style: TextStyle(
                                      decoration: taskItem.isCompleted
                                          ? TextDecoration.lineThrough
                                          : TextDecoration.none)),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                          icon: const Icon(Icons.edit, color: Colors.orange),
                          onPressed: () =>
                              _showEditDialog(context, index, taskItem)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.black),
                          onPressed: () => onDelete(index)),
                    ],
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, int index, TaskItem taskItem) {
    final TextEditingController _editController =
        TextEditingController(text: taskItem.text);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Task '),
        content: TextField(
            controller: _editController,
            decoration: const InputDecoration(
                labelText: 'Description', border: OutlineInputBorder())),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.red),
              )),
          TextButton(
            onPressed: () {
              if (_editController.text.isNotEmpty) {
                onEdit(index, _editController.text);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }
}

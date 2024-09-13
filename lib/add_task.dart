import 'package:flutter/material.dart';
import 'model.dart';

class AddTaskBottomSheet extends StatefulWidget {
  final Function(Task) onTaskAdded;

  const AddTaskBottomSheet({Key? key, required this.onTaskAdded})
      : super(key: key);

  @override
  _AddTaskBottomSheetState createState() => _AddTaskBottomSheetState();
}

class _AddTaskBottomSheetState extends State<AddTaskBottomSheet> {
  final List<TaskItem> _items = [];
  TimeOfDay? _selectedTime;
  final TextEditingController _taskDescriptionController =
      TextEditingController();

  Future<void> _pickTime(BuildContext context) async {
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
        _selectedTime = picked;
      });
    }
  }

  void _addTaskItem() {
    final taskDescription = _taskDescriptionController.text;
    if (taskDescription.isNotEmpty) {
      setState(() {
        _items.add(TaskItem(text: taskDescription));
        _taskDescriptionController.clear();
      });
    }
  }

  void _addTask() {
    if (_selectedTime != null && _items.isNotEmpty) {
      widget.onTaskAdded(
          Task(time: _selectedTime!.format(context), items: _items));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Add Task',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Text('Time   '),
                  ElevatedButton.icon(
                    onPressed: () => _pickTime(context),
                    icon: const Icon(
                      Icons.access_time,
                      color: Colors.black,
                    ),
                    label: Text(
                      _selectedTime == null
                          ? '                  '
                          : ' ${_selectedTime!.format(context)}',
                      style: const TextStyle(color: Colors.black),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                  controller: _taskDescriptionController,
                  decoration: const InputDecoration(
                      labelText: 'Description', border: OutlineInputBorder())),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                onPressed: _addTaskItem,
                label: const Text(
                  '+',
                  style: TextStyle(fontSize: 17, color: Colors.black),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 222, 217, 217),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_items.isNotEmpty)
                ..._items.map((item) => ListTile(
                      title: Text(item.text),
                      tileColor: const Color.fromARGB(255, 238, 228, 228),
                      contentPadding: const EdgeInsets.all(8),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                          side: const BorderSide(color: Colors.black)),
                    )),
              const SizedBox(height: 16),
              ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Confirm',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

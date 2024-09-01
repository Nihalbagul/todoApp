import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/todo_model.dart';
import '../providers/todo_provider.dart';
import 'package:intl/intl.dart';

class EditTaskDialog extends StatefulWidget {
  final TodoModel task;

  const EditTaskDialog({Key? key, required this.task}) : super(key: key);

  @override
  _EditTaskDialogState createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  TimeOfDay? _reminderTime;
  late PriorityLevel _selectedPriority;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.todoTitle);
    _descriptionController =
        TextEditingController(text: widget.task.description);
    _dueDate = widget.task.dueDate;
    _reminderTime = widget.task.reminder;
    _selectedPriority = widget.task.priority;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return DateFormat.yMMMd().format(date);
  }

  String _formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Task"),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Task Title',
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Task Description',
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(_dueDate == null
                  ? 'No Due Date'
                  : 'Due Date: ${_formatDate(_dueDate!)}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2101),
                );
                if (picked != null) {
                  setState(() {
                    _dueDate = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              title: Text(_reminderTime == null
                  ? 'No Reminder'
                  : 'Reminder Time: ${_formatTime(_reminderTime!)}'),
              trailing: const Icon(Icons.access_time),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: _reminderTime ?? TimeOfDay.now(),
                );
                if (picked != null) {
                  setState(() {
                    _reminderTime = picked;
                  });
                }
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<PriorityLevel>(
              value: _selectedPriority,
              items: PriorityLevel.values
                  .map(
                    (priority) => DropdownMenuItem(
                      value: priority,
                      child: Text(priority.toString().split('.').last),
                    ),
                  )
                  .toList(),
              onChanged: (PriorityLevel? newValue) {
                setState(() {
                  _selectedPriority = newValue!;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Priority',
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text("Save"),
          onPressed: () {
            if (_titleController.text.isNotEmpty) {
              Provider.of<TodoProvider>(context, listen: false).updateTask(
                widget.task,
                _titleController.text,
                _descriptionController.text,
                _dueDate,
                _reminderTime,
                _selectedPriority,
              );
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

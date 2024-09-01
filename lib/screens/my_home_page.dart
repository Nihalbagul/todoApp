import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/todo_provider.dart';
import '../model/todo_model.dart';
import '../widgets/todo_action.dart';
import '../widgets/edit_task_dialog.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ToDo App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () {
              Provider.of<TodoProvider>(context, listen: false)
                  .toggleSortOrder();
            },
            tooltip: 'Toggle Sort Order',
          ),
          PopupMenuButton<SortCriterion>(
            onSelected: (SortCriterion criterion) {
              Provider.of<TodoProvider>(context, listen: false)
                  .setSortCriterion(criterion);
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuEntry<SortCriterion>>[
              const PopupMenuItem<SortCriterion>(
                value: SortCriterion.priority,
                child: Text('Sort by Priority'),
              ),
              const PopupMenuItem<SortCriterion>(
                value: SortCriterion.dueDate,
                child: Text('Sort by Due Date'),
              ),
              const PopupMenuItem<SortCriterion>(
                value: SortCriterion.creationDate,
                child: Text('Sort by Creation Date'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search tasks...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                Provider.of<TodoProvider>(context, listen: false)
                    .setSearchQuery(value);
              },
            ),
          ),
          Expanded(
            child: TodoAction(
              onEditTask: (task) => _showEditDialog(task),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddTextDialog();
        },
        child: const Icon(Icons.add),
        tooltip: "Add a todo",
      ),
    );
  }

  void _showEditDialog(TodoModel task) {
    showDialog(
      context: context,
      builder: (context) {
        return EditTaskDialog(task: task);
      },
    );
  }

  Future<void> _showAddTextDialog() async {
    final _titleController = TextEditingController();
    final _descriptionController = TextEditingController();
    DateTime? _dueDate;
    TimeOfDay? _reminderTime;
    PriorityLevel _selectedPriority = PriorityLevel.medium;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add a new Task"),
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
                      : 'Due Date: ${_dueDate!.toLocal()}'.split(' ')[0]),
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
                      : 'Reminder Time: ${_reminderTime!.format(context)}'),
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
              child: const Text("Add"),
              onPressed: () {
                if (_titleController.text.isNotEmpty) {
                  Provider.of<TodoProvider>(context, listen: false).addTask(
                    _titleController.text,
                    description: _descriptionController.text,
                    priority: _selectedPriority,
                    dueDate: _dueDate,
                    reminder: _reminderTime,
                  );
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }
}

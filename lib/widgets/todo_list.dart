import 'package:flutter/material.dart';
import '../model/todo_model.dart';
import 'package:intl/intl.dart';

class TodoList extends StatelessWidget {
  final List<TodoModel> tasks;
  final void Function(TodoModel) onToggleTask;
  final void Function(TodoModel) onDeleteTask;
  final void Function(TodoModel) onEditTask;

  const TodoList({
    Key? key,
    required this.tasks,
    required this.onToggleTask,
    required this.onDeleteTask,
    required this.onEditTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        final dueDate = task.dueDate != null
            ? DateFormat('yyyy-MM-dd').format(task.dueDate!)
            : 'No Due Date';
        final reminderTime = task.reminder != null
            ? task.reminder!.format(context)
            : 'No Reminder';

        // Determine the color based on the priority level
        Color cardColor;
        switch (task.priority) {
          case PriorityLevel.low:
            cardColor = Colors.green[100]!;
            break;
          case PriorityLevel.medium:
            cardColor = Colors.yellow[100]!;
            break;
          case PriorityLevel.high:
            cardColor = Colors.red[100]!;
            break;
        }

        return Card(
          color: cardColor, // Set the card color based on priority
          child: ListTile(
            title: Text(
              task.todoTitle,
              style: TextStyle(
                decoration: task.completed ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.description ?? 'No Description'),
                const SizedBox(height: 4),
                Text('Due Date: $dueDate'),
                Text('Reminder: $reminderTime'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(
                    task.completed
                        ? Icons.check_box
                        : Icons.check_box_outline_blank,
                  ),
                  onPressed: () => onToggleTask(task),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => onEditTask(task),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => onDeleteTask(task),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

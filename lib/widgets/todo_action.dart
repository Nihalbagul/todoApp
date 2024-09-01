import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/todo_model.dart';
import '../providers/todo_provider.dart';
import '../widgets/todo_list.dart';

class TodoAction extends StatelessWidget {
  final void Function(TodoModel) onEditTask;

  const TodoAction({
    Key? key,
    required this.onEditTask,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TodoProvider>(
      builder: (context, todoProvider, child) {
        return TodoList(
          tasks: todoProvider.allTasks,
          onToggleTask: (task) => todoProvider.toggleTask(task),
          onDeleteTask: (task) => todoProvider.deleteTask(task),
          onEditTask: onEditTask,
        );
      },
    );
  }
}

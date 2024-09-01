import 'package:flutter/material.dart';

enum PriorityLevel { low, medium, high }

class TodoModel {
  String todoTitle;
  String? description;
  bool completed;
  DateTime? dueDate;
  TimeOfDay? reminder;
  PriorityLevel priority;
  final DateTime creationDate;

  TodoModel({
    required this.todoTitle,
    this.description,
    this.completed = false,
    this.dueDate,
    this.reminder,
    this.priority = PriorityLevel.medium,
  }) : creationDate = DateTime.now();

  void toggleCompleted() {
    completed = !completed;
  }

  void update(String newTitle, String? newDescription, DateTime? newDueDate,
      TimeOfDay? newReminder, PriorityLevel newPriority) {
    todoTitle = newTitle;
    description = newDescription;
    dueDate = newDueDate;
    reminder = newReminder;
    priority = newPriority;
  }

  // Convert a TodoModel into a Map
  Map<String, dynamic> toJson() => {
        'todoTitle': todoTitle,
        'description': description,
        'completed': completed,
        'dueDate': dueDate?.toIso8601String(),
        'reminder': reminder != null
            ? {'hour': reminder!.hour, 'minute': reminder!.minute}
            : null,
        'priority': priority.index,
        'creationDate': creationDate.toIso8601String(),
      };

  // Convert a Map into a TodoModel
  factory TodoModel.fromJson(Map<String, dynamic> json) => TodoModel(
        todoTitle: json['todoTitle'],
        description: json['description'],
        completed: json['completed'],
        dueDate:
            json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        reminder: json['reminder'] != null
            ? TimeOfDay(
                hour: json['reminder']['hour'],
                minute: json['reminder']['minute'],
              )
            : null,
        priority: PriorityLevel.values[json['priority']],
      );
}

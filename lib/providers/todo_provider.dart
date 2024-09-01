import 'dart:collection';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/todo_model.dart';

// Define SortCriterion enum here
enum SortCriterion {
  priority,
  dueDate,
  creationDate,
}

class TodoProvider with ChangeNotifier {
  List<TodoModel> _tasks = [];
  SortCriterion _sortCriterion = SortCriterion.creationDate;
  bool _isAscending = true;
  String _searchQuery = '';

  TodoProvider() {
    _loadTasksFromPrefs(); // Load tasks when provider is initialized
  }

  UnmodifiableListView<TodoModel> get allTasks {
    List<TodoModel> filteredTasks = _tasks
        .where((task) =>
            task.todoTitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            (task.description != null &&
                task.description!
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase())))
        .toList();

    filteredTasks.sort((a, b) {
      int comparison;
      switch (_sortCriterion) {
        case SortCriterion.priority:
          comparison = a.priority.index.compareTo(b.priority.index);
          break;
        case SortCriterion.dueDate:
          comparison = (a.dueDate ?? DateTime(2101))
              .compareTo(b.dueDate ?? DateTime(2101));
          break;
        case SortCriterion.creationDate:
        default:
          comparison = a.creationDate.compareTo(b.creationDate);
          break;
      }
      return _isAscending ? comparison : -comparison;
    });
    return UnmodifiableListView(filteredTasks);
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSortCriterion(SortCriterion criterion) {
    _sortCriterion = criterion;
    notifyListeners();
  }

  void toggleSortOrder() {
    _isAscending = !_isAscending;
    notifyListeners();
  }

  void addTask(String task,
      {String? description,
      PriorityLevel priority = PriorityLevel.medium,
      DateTime? dueDate,
      TimeOfDay? reminder}) {
    _tasks.add(TodoModel(
      todoTitle: task,
      description: description,
      priority: priority,
      dueDate: dueDate,
      reminder: reminder,
    ));
    _saveTasksToPrefs(); // Save tasks after adding
    notifyListeners();
  }

  void toggleTask(TodoModel task) {
    final taskIndex = _tasks.indexOf(task);
    _tasks[taskIndex].toggleCompleted();
    _saveTasksToPrefs(); // Save tasks after toggling completion
    notifyListeners();
  }

  void deleteTask(TodoModel task) {
    _tasks.remove(task);
    _saveTasksToPrefs(); // Save tasks after deletion
    notifyListeners();
  }

  void updateTask(TodoModel task, String newTitle, String? newDescription,
      DateTime? newDueDate, TimeOfDay? newReminder, PriorityLevel newPriority) {
    final taskIndex = _tasks.indexOf(task);
    _tasks[taskIndex]
        .update(newTitle, newDescription, newDueDate, newReminder, newPriority);
    _saveTasksToPrefs(); // Save tasks after updating
    notifyListeners();
  }

  Future<void> _saveTasksToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> tasks =
        _tasks.map((task) => jsonEncode(task.toJson())).toList();
    prefs.setStringList('tasks', tasks);
  }

  Future<void> _loadTasksFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? taskStrings = prefs.getStringList('tasks');
    if (taskStrings != null) {
      _tasks = taskStrings
          .map((taskString) => TodoModel.fromJson(jsonDecode(taskString)))
          .toList();
      notifyListeners();
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'task.dart';
import '../services/task_storage_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  
  TaskProvider() {
    _loadTasks();
  }
  
  Future<void> _loadTasks() async {
    _tasks = await TaskStorageService.loadTasks();
    notifyListeners();
  }

  List<Task> get tasks => List.unmodifiable(_tasks);
  List<Task> get activeTasks => _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    await TaskStorageService.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      await TaskStorageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    _tasks.removeWhere((task) => task.id == taskId);
    await TaskStorageService.saveTasks(_tasks);
    notifyListeners();
  }

  Future<void> toggleTaskStatus(String taskId) async {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex] = _tasks[taskIndex].copyWith(
        isCompleted: !_tasks[taskIndex].isCompleted,
      );
      await TaskStorageService.saveTasks(_tasks);
      notifyListeners();
    }
  }

  /// Removes all completed tasks from the list
  Future<bool> clearCompletedTasks() async {
    try {
      final initialCount = _tasks.length;
      _tasks.removeWhere((task) => task.isCompleted);
      if (_tasks.length < initialCount) {
        await TaskStorageService.saveTasks(_tasks);
        notifyListeners();
        return true;
      }
      return false; // No tasks were removed
    } catch (e) {
      debugPrint('Error clearing completed tasks: $e');
      return false;
    }
  }
}

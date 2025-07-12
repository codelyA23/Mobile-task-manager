import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';

class TaskStorageService {
  static const String _tasksKey = 'tasks';

  // Save tasks to shared preferences
  static Future<void> saveTasks(List<Task> tasks) async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = tasks.map((task) => task.toJson()).toList();
    await prefs.setString(_tasksKey, json.encode(tasksJson));
  }

  // Load tasks from shared preferences
  static Future<List<Task>> loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstLaunch = prefs.getBool('is_first_launch') ?? true;
    final tasksJson = prefs.getString(_tasksKey);

    // If first launch, create default tasks
    if (isFirstLaunch) {
      await prefs.setBool('is_first_launch', false);
      final defaultTasks = _createDefaultTasks();
      await saveTasks(defaultTasks);
      return defaultTasks;
    }

    // If no tasks exist but it's not first launch, return empty list
    if (tasksJson == null || tasksJson.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> decoded = json.decode(tasksJson);
      return decoded.map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      debugPrint('Error loading tasks: $e');
      return [];
    }
  }

  // Create default tasks for first-time users
  static List<Task> _createDefaultTasks() {
    final now = DateTime.now();
    return [
      Task(
        title: 'Welcome to TaskMaster! 👋',
        description: 'Tap the + button to add a new task',
        dueDate: now.add(const Duration(days: 7)),
      ),
      Task(
        title: 'Swipe to delete',
        description: 'Swipe left on a task to delete it',
        dueDate: now.add(const Duration(days: 1)),
      ),
      Task(
        title: 'Tap for details',
        description: 'Tap a task to see more details',
        dueDate: now.add(const Duration(hours: 12)),
      ),
    ];
  }

  // Clear all tasks
  static Future<void> clearAllTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tasksKey);
  }
}

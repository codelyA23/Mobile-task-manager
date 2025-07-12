// This is a basic Flutter widget test for the TaskMaster app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:task_master/models/task_provider.dart';
import 'package:task_master/models/task.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Task Model Tests', () {
    test('Task should be created with correct properties', () {
      final task = Task(
        title: 'Test Task',
        description: 'This is a test task',
        isCompleted: false,
      );
      
      expect(task.title, 'Test Task');
      expect(task.description, 'This is a test task');
      expect(task.isCompleted, false);
      expect(task.id, isNotEmpty);
      expect(task.dueDate, isNull);
    });
    
    test('Task copyWith should create a new instance with updated fields', () {
      final original = Task(
        title: 'Original',
        description: 'Original description',
        isCompleted: false,
      );
      
      final updated = original.copyWith(
        title: 'Updated',
        isCompleted: true,
      );
      
      expect(updated.id, original.id);
      expect(updated.title, 'Updated');
      expect(updated.description, original.description);
      expect(updated.isCompleted, true);
    });
  });

  group('TaskProvider Tests', () {
    late TaskProvider taskProvider;
    
    setUp(() {
      taskProvider = TaskProvider();
    });
    
    test('Initial tasks should be loaded', () {
      expect(taskProvider.tasks.length, 3); // We have 3 default tasks
    });
    
    test('Should add a new task', () async {
      final initialCount = taskProvider.tasks.length;
      final task = Task(
        title: 'New Task',
        description: 'New task description',
        isCompleted: false,
      );
      
      await taskProvider.addTask(task);
      
      expect(taskProvider.tasks.length, initialCount + 1);
      expect(taskProvider.tasks.last.title, 'New Task');
    });
    
    test('Should toggle task completion status', () async {
      // Add a task
      final task = Task(
        title: 'Toggle Test',
        description: 'Test toggling',
        isCompleted: false,
      );
      await taskProvider.addTask(task);
      
      // Toggle completion
      taskProvider.toggleTaskStatus(task.id);
      final updatedTask = taskProvider.tasks.firstWhere((t) => t.id == task.id);
      expect(updatedTask.isCompleted, true);
      
      // Toggle back
      taskProvider.toggleTaskStatus(task.id);
      final toggledBackTask = taskProvider.tasks.firstWhere((t) => t.id == task.id);
      expect(toggledBackTask.isCompleted, false);
    });
    
    test('Should update a task', () async {
      // Add a task
      final task = Task(
        title: 'Original Title',
        description: 'Original description',
        isCompleted: false,
      );
      await taskProvider.addTask(task);
      
      // Update the task
      final updatedTask = task.copyWith(
        title: 'Updated Title',
        description: 'Updated description',
        isCompleted: true,
      );
      taskProvider.updateTask(updatedTask);
      
      final retrievedTask = taskProvider.tasks.firstWhere((t) => t.id == task.id);
      expect(retrievedTask.title, 'Updated Title');
      expect(retrievedTask.description, 'Updated description');
      expect(retrievedTask.isCompleted, true);
    });
    
    test('Should delete a task', () async {
      // Add a task
      final task = Task(
        title: 'Delete Test',
        description: 'Test deletion',
        isCompleted: false,
      );
      await taskProvider.addTask(task);
      
      final taskId = task.id;
      final initialCount = taskProvider.tasks.length;
      
      // Delete the task
      taskProvider.deleteTask(taskId);
      
      expect(taskProvider.tasks.length, initialCount - 1);
      expect(
        taskProvider.tasks.any((t) => t.id == taskId),
        false,
      );
    });
    
    test('Should get active and completed tasks', () async {
      // Add some tasks
      await taskProvider.addTask(Task(title: 'Task 1', isCompleted: false));
      await taskProvider.addTask(Task(title: 'Task 2', isCompleted: true));
      await taskProvider.addTask(Task(title: 'Task 3', isCompleted: false));
      
      expect(taskProvider.activeTasks.every((task) => !task.isCompleted), isTrue);
      expect(taskProvider.completedTasks.every((task) => task.isCompleted), isTrue);
    });
  });
}

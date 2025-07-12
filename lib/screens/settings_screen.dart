import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter/services.dart';
import '../models/settings.dart';
import '../models/task_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<AppSettings>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              final success = await settings.saveSettings();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success 
                      ? 'Settings saved successfully'
                      : 'Failed to save settings'),
                    backgroundColor: success 
                      ? Colors.green 
                      : Theme.of(context).colorScheme.error,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Theme Settings
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Appearance',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildThemeOption(
                  context,
                  title: 'Dark Mode',
                  value: settings.themeMode == ThemeMode.dark
                      ? 'On'
                      : settings.themeMode == ThemeMode.light
                          ? 'Off'
                          : 'System',
                  icon: isDark ? LineIcons.moon : LineIcons.sun,
                  onTap: () async {
                    await _showThemeOptions(context, settings);
                    await settings.saveSettings();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Theme mode updated')),
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Task Settings
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Task Settings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildToggleOption(
                  context,
                  title: 'Show Completed Tasks',
                  value: settings.showCompletedTasks,
                  onChanged: settings.toggleShowCompletedTasks,
                  icon: LineIcons.checkSquare,
                ),
                _buildDivider(),
                _buildToggleOption(
                  context,
                  title: 'Enable Notifications',
                  value: settings.enableNotifications,
                  onChanged: settings.toggleNotifications,
                  icon: LineIcons.bell,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Data Management
          Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Data Management',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                _buildListTile(
                  context,
                  title: 'Export Tasks',
                  icon: LineIcons.fileExport,
                  onTap: () => _exportTasks(context),
                ),
                _buildDivider(),
                _buildListTile(
                  context,
                  title: 'Clear Completed Tasks',
                  icon: LineIcons.trash,
                  onTap: () => _clearCompletedTasks(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).hintColor,
                ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right),
        ],
      ),
      onTap: onTap,
    );
  }

  Widget _buildToggleOption(
    BuildContext context, {
    required String title,
    required bool value,
    required Future<bool> Function() onChanged,
    required IconData icon,
  }) {
    bool isLoading = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return ListTile(
          leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
          title: Text(title),
          trailing: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Switch(
                  value: value,
                  onChanged: (newValue) async {
                    setState(() => isLoading = true);
                    try {
                      final success = await onChanged();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              success 
                                ? 'Setting updated successfully'
                                : 'Failed to update setting',
                            ),
                            backgroundColor: 
                              success 
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.error,
                            duration: const Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      }
                    } finally {
                      if (context.mounted) {
                        setState(() => isLoading = false);
                      }
                    }
                  },
                  activeColor: Theme.of(context).colorScheme.primary,
                ),
        );
      },
    );
  }

  Widget _buildListTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Padding(
      padding: EdgeInsets.only(left: 72.0, right: 16.0),
      child: Divider(height: 1),
    );
  }

  Future<void> _showThemeOptions(BuildContext context, AppSettings settings) async {
    final result = await showModalBottomSheet<ThemeMode>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('Light Theme'),
                value: ThemeMode.light,
                groupValue: settings.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    Navigator.pop(context, value);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark Theme'),
                value: ThemeMode.dark,
                groupValue: settings.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    Navigator.pop(context, value);
                  }
                },
              ),
              RadioListTile<ThemeMode>(
                title: const Text('System Default'),
                value: ThemeMode.system,
                groupValue: settings.themeMode,
                onChanged: (ThemeMode? value) {
                  if (value != null) {
                    Navigator.pop(context, value);
                  }
                },
              ),
            ],
          ),
        );
      },
    );

    if (result != null) {
      final success = await settings.setThemeMode(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success 
              ? 'Theme updated successfully' 
              : 'Failed to update theme'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _exportTasks(BuildContext context) async {
    try {
      final taskProvider = context.read<TaskProvider>();
      final tasks = taskProvider.tasks;
      
      if (tasks.isEmpty) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No tasks to export'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }
      
      final buffer = StringBuffer();
      buffer.writeln('TaskMaster Export - ${DateTime.now().toString().split('.')[0]}');
      buffer.writeln('=' * 50);
      
      for (var i = 0; i < tasks.length; i++) {
        final task = tasks[i];
        buffer.writeln('${i + 1}. ${task.title}');
        if (task.description.isNotEmpty) {
          buffer.writeln('   ${task.description}');
        }
        buffer.writeln('   Status: ${task.isCompleted ? '✅ Completed' : '⏳ Pending'}');
        if (task.dueDate != null) {
          buffer.writeln('   Due: ${task.dueDate.toString().split('.')[0]}');
        }
        if (i < tasks.length - 1) buffer.writeln('-' * 30);
      }
      
      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tasks exported to clipboard!'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export tasks: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _clearCompletedTasks(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Clear Completed Tasks'),
          content: Text(
              'Are you sure you want to delete all completed tasks? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('CANCEL'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              child: Text('CLEAR'),
            ),
          ],
        );
      },
    ) ?? false;

    if (confirmed && context.mounted) {
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      final taskProvider = context.read<TaskProvider>();
      
      try {
        final success = await taskProvider.clearCompletedTasks();
        
        if (context.mounted) {
          if (success) {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: const Text('Completed tasks cleared successfully'),
                backgroundColor: Theme.of(context).colorScheme.primary,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          } else {
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Text('No completed tasks to clear'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Failed to clear completed tasks: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:line_icons/line_icons.dart';
import '../models/task.dart';
import '../models/task_provider.dart';
import '../models/settings.dart';
import '../widgets/task_item.dart';
import 'add_task_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskMaster'),
        actions: [
          IconButton(
            icon: const Icon(LineIcons.cog),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
            tooltip: 'Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: false,
          tabs: const [
            Tab(icon: Icon(LineIcons.list), text: 'All'),
            Tab(icon: Icon(LineIcons.checkCircle), text: 'Active'),
            Tab(icon: Icon(LineIcons.checkSquare), text: 'Completed'),
          ],
          labelColor: Theme.of(context).colorScheme.primary,
          indicatorColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).hintColor,
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(LineIcons.search),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 0,
                  ),
                  fillColor: Theme.of(context).cardColor,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTaskList(context, (tasks) => tasks),
                  _buildTaskList(
                    context,
                    (tasks) =>
                        tasks.where((task) => !task.isCompleted).toList(),
                  ),
                  _buildTaskList(
                    context,
                    (tasks) => tasks.where((task) => task.isCompleted).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTaskScreen()),
          );

          if (result != null && result is Task) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task added successfully!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          }
        },
        child: const Icon(LineIcons.plus),
      ),
    );
  }

  List<Task> _filterTasksBySearch(List<Task> tasks) {
    if (_searchQuery.isEmpty) return tasks;

    return tasks.where((task) {
      final title = task.title.toLowerCase();
      final description = task.description.toLowerCase();
      return title.contains(_searchQuery) || description.contains(_searchQuery);
    }).toList();
  }

  Widget _buildTaskList(
    BuildContext context,
    List<Task> Function(List<Task>) filterTasks,
  ) {
    return Consumer2<TaskProvider, AppSettings>(
      builder: (
        BuildContext context,
        TaskProvider taskProvider,
        AppSettings settings,
        Widget? child,
      ) {
        try {
          // First apply the tab filter, then apply search filter
          List<Task> filteredTasks = filterTasks(taskProvider.tasks);
          
          // Apply showCompletedTasks setting for the 'All' tab
          if (_tabController.index == 0 && !settings.showCompletedTasks) {
            filteredTasks = filteredTasks.where((task) => !task.isCompleted).toList();
          }
          
          filteredTasks = _filterTasksBySearch(filteredTasks);

          if (filteredTasks.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _searchQuery.isEmpty
                          ? Icons.task_alt_outlined
                          : Icons.search_off,
                      size: 64,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchQuery.isEmpty
                          ? 'No tasks yet!\nTap + to add a new task'
                          : 'No tasks found for "$_searchQuery"',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(
              bottom: 100,
              left: 16,
              right: 16,
              top: 8,
            ),
            itemCount: filteredTasks.length,
            itemBuilder: (BuildContext context, int index) {
              if (index >= filteredTasks.length) return const SizedBox.shrink();

              final task = filteredTasks[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: TaskItem(
                  key: ValueKey(task.id),
                  task: task,
                  onToggle: () async {
                    await taskProvider.toggleTaskStatus(task.id);
                  },
                  onDelete: () => _showDeleteConfirmation(context, task.id),
                  onTap: () => _showTaskDetails(context, task),
                ),
              );
            },
          );
        } catch (e, stackTrace) {
          debugPrint('Error in _buildTaskList: $e');
          debugPrint('Stack trace: $stackTrace');
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading tasks',
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please try again later',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Future<void> _showDeleteConfirmation(
    BuildContext context,
    String taskId,
  ) async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Task'),
              content: const Text('Are you sure you want to delete this task?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'DELETE',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmed && context.mounted) {
      context.read<TaskProvider>().deleteTask(taskId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Task deleted')));
      }
    }
  }

  Future<void> _showTaskDetails(BuildContext context, Task task) async {
    if (!mounted) return;

    final taskProvider = context.read<TaskProvider>();

    if (!mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return TaskDetailsBottomSheet(
          task: task,
          onEdit: () {
            Navigator.pop(context); // Close the bottom sheet
            if (context.mounted) {
              _navigateToEditTask(context, task);
            }
          },
          onDelete: () {
            Navigator.pop(context); // Close the bottom sheet
            if (context.mounted) {
              _showDeleteConfirmation(context, task.id);
            }
          },
          onToggleComplete: () async {
            try {
              await taskProvider.toggleTaskStatus(task.id);
              if (context.mounted) {
                Navigator.pop(context); // Close the bottom sheet
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to update task status'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  Future<void> _navigateToEditTask(BuildContext context, Task task) async {
    // Navigate to edit task screen with the current task data
    // You'll need to implement the edit functionality in AddTaskScreen
    // and pass the task to be edited
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddTaskScreen(taskToEdit: task)),
    );

    if (result == true && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task updated successfully')),
      );
    }
  }
}

class TaskDetailsBottomSheet extends StatelessWidget {
  final Task task;
  final Function()? onEdit;
  final Function()? onDelete;
  final Function()? onToggleComplete;

  const TaskDetailsBottomSheet({
    super.key,
    required this.task,
    this.onEdit,
    this.onDelete,
    this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottomPadding = MediaQuery.of(context).viewInsets.bottom + 16;

    return Container(
      padding: EdgeInsets.only(
        left: 24.0,
        right: 24.0,
        top: 16.0,
        bottom: bottomPadding,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Task title and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status indicator
                Container(
                  width: 8,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        task.isCompleted
                            ? Colors.green
                            : theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 12),
                // Title and status text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: task.isCompleted
                              ? theme.colorScheme.onSurface.withOpacity(0.8)
                              : theme.colorScheme.onSurface,
                          decoration: task.isCompleted
                              ? TextDecoration.combine([
                                  TextDecoration.lineThrough,
                                  TextDecoration.underline,
                                ])
                              : null,
                          decorationThickness: 2.0,
                          decorationColor: theme.colorScheme.primary,
                          letterSpacing: 0.25,
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color:
                              task.isCompleted
                                  ? Colors.green.withAlpha((0.1 * 255).round())
                                  : theme.colorScheme.primary.withAlpha(
                                    (0.1 * 255).round(),
                                  ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          task.isCompleted ? 'Completed' : 'In Progress',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color:
                                task.isCompleted
                                    ? Colors.green
                                    : theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Edit and delete buttons
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(LineIcons.edit, size: 20),
                      onPressed: onEdit,
                      tooltip: 'Edit Task',
                    ),
                    IconButton(
                      icon: const Icon(LineIcons.trash, size: 20),
                      onPressed: onDelete,
                      tooltip: 'Delete Task',
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Description section
            if (task.description.isNotEmpty) ...[
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Text(task.description, style: theme.textTheme.bodyLarge),
              ),
              const SizedBox(height: 24),
            ],

            // Due date and time section
            if (task.dueDate != null) ...[
              const Text(
                'Due Date & Time',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: Column(
                  children: [
                    _buildDetailRow(
                      context,
                      icon: LineIcons.calendar,
                      label: 'Due Date',
                      value: _formatDate(task.dueDate!),
                    ),
                    if (task.dueDate!.hour != 0 ||
                        task.dueDate!.minute != 0) ...[
                      const Divider(height: 24),
                      _buildDetailRow(
                        context,
                        icon: LineIcons.clock,
                        label: 'Time',
                        value:
                            '${task.dueDate!.hour.toString().padLeft(2, '0')}:${task.dueDate!.minute.toString().padLeft(2, '0')}',
                      ),
                    ],
                    const SizedBox(height: 8),
                    _buildTimeRemaining(context, task.dueDate!),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Toggle complete button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onToggleComplete,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor:
                      task.isCompleted
                          ? Colors.green.withOpacity(0.1)
                          : theme.colorScheme.primary.withOpacity(0.1),
                  foregroundColor:
                      task.isCompleted
                          ? Colors.green
                          : theme.colorScheme.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color:
                          task.isCompleted
                              ? Colors.green.withOpacity(0.5)
                              : theme.colorScheme.primary.withOpacity(0.5),
                    ),
                  ),
                ),
                icon: Icon(
                  task.isCompleted ? LineIcons.checkCircle : LineIcons.check,
                  size: 20,
                ),
                label: Text(
                  task.isCompleted ? 'Mark as Incomplete' : 'Mark as Complete',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);
    final hintColor = theme.hintColor;
    final iconColor = Color.alphaBlend(
      hintColor.withAlpha((0.7 * 255).round()),
      theme.scaffoldBackgroundColor,
    );
    final textColor = Color.alphaBlend(
      hintColor.withAlpha((0.8 * 255).round()),
      theme.scaffoldBackgroundColor,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(color: textColor),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeRemaining(BuildContext context, DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now);
    
    // A task is considered overdue if the due date has passed (difference is negative)
    // and it's not the same day
    final isOverdue = difference.isNegative && 
                     (difference.inDays < -1 || 
                      (now.day != dueDate.day || 
                       now.month != dueDate.month || 
                       now.year != dueDate.year));

    final (String timeRemaining, Color statusColor) = _getTimeRemainingInfo(
      difference,
      isOverdue,
    );
    final backgroundColor = statusColor.withAlpha((0.1 * 255).round());

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isOverdue ? LineIcons.exclamationCircle : LineIcons.clock,
            size: 16,
            color: statusColor,
          ),
          const SizedBox(width: 6),
          Text(
            timeRemaining,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  (String, Color) _getTimeRemainingInfo(Duration difference, bool isOverdue) {
    if (isOverdue) {
      final daysOverdue = -difference.inDays;
      if (daysOverdue > 1) {
        return ('$daysOverdue days overdue', Colors.red);
      } else if (daysOverdue == 1) {
        return ('1 day overdue', Colors.red);
      } else {
        // Less than a day overdue, show hours
        final hoursOverdue = -difference.inHours;
        if (hoursOverdue > 1) {
          return ('$hoursOverdue hours overdue', Colors.red);
        } else {
          return ('Less than an hour overdue', Colors.red);
        }
      }
    } else if (difference.inDays > 1) {
      return ('${difference.inDays} days remaining', Colors.orange);
    } else if (difference.inDays == 1) {
      return ('1 day remaining', Colors.orange);
    } else if (difference.inHours > 1) {
      return ('${difference.inHours} hours remaining', Colors.blue);
    } else if (difference.inMinutes > 1) {
      return ('${difference.inMinutes} minutes remaining', Colors.blue);
    } else if (difference.inMinutes == 1) {
      return ('1 minute remaining', Colors.blue);
    } else {
      return ('Due now', Colors.blue);
    }
  }

  String _formatDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}, ${date.year}';
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return monthNames[month - 1];
  }
}

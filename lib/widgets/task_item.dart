import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/task.dart';
import '../theme/app_theme.dart';

// Helper extension to replace withOpacity with a more precise alpha blending
extension ColorExtension on Color {
  Color withAlphaValue(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0, 'opacity must be between 0.0 and 1.0');
    return withOpacity(opacity);
  }
}

class TaskItem extends StatefulWidget {
  final Task task;
  final Future<void> Function() onToggle;
  final VoidCallback onDelete;
  final VoidCallback? onTap;

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onDelete,
    this.onTap,
  });

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Removed unused isDarkMode variable
    
    Future<void> handleToggle() async {
      if (_isProcessing) return;
      setState(() => _isProcessing = true);
      try {
        await widget.onToggle();
      } finally {
        if (mounted) {
          setState(() => _isProcessing = false);
        }
      }
    }
    
    return Dismissible(
      key: Key(widget.task.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Color.alphaBlend(
            AppTheme.errorColor.withAlphaValue(0.1),
            theme.cardColor,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        child: const Icon(
          LineIcons.trash,
          color: AppTheme.errorColor,
          size: 24,
        ),
      ),
      confirmDismiss: (direction) async {
        // Show a confirmation dialog
        final shouldDelete = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Task'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                child: const Text('DELETE'),
              ),
            ],
          ),
        ) ?? false; // return false if null (dialog dismissed)

        if (shouldDelete) {
          widget.onDelete();
          return true; // Allow dismiss
        }
        return false; // Prevent dismiss
      },
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: widget.task.isCompleted 
                ? theme.cardColor
                : theme.brightness == Brightness.dark
                    ? Colors.grey[900] // Darker background for active tasks in dark mode
                    : theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: widget.task.isCompleted
                    ? Colors.black.withAlphaValue(0.05)
                    : theme.colorScheme.primary.withAlphaValue(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: widget.task.isCompleted 
                ? null 
                : Border.all(
                    color: theme.colorScheme.primary.withAlphaValue(0.3),
                    width: 1,
                  ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Checkbox
                GestureDetector(
                  onTap: handleToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: widget.task.isCompleted
                          ? theme.colorScheme.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: _isProcessing
                            ? theme.hintColor.withAlphaValue(0.3)
                            : widget.task.isCompleted
                                ? theme.colorScheme.primary
                                : theme.hintColor.withAlphaValue(0.5),
                        width: 2,
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                            ),
                          )
                        : widget.task.isCompleted
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Task details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextStyle.merge(
                        style: TextStyle(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        child: Text(
                          widget.task.title,
                          style: widget.task.isCompleted
                              ? TextStyle(
                                  color: theme.brightness == Brightness.dark
                                      ? Colors.white70
                                      : Colors.black54,
                                  decoration: TextDecoration.lineThrough,
                                  decorationThickness: 2.0,
                                  decorationColor: theme.colorScheme.primary,
                                )
                              : null,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      
                      if (widget.task.description.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.task.description,
                          style: TextStyle(
                            color: theme.brightness == Brightness.dark
                                ? widget.task.isCompleted
                                    ? Colors.white60
                                    : Colors.white70
                                : widget.task.isCompleted
                                    ? Colors.black45
                                    : Colors.black54,
                            fontSize: 14,
                            decoration: widget.task.isCompleted 
                                ? TextDecoration.lineThrough
                                : null,
                            decorationThickness: 1.5,
                            decorationColor: theme.colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      
                      if (widget.task.dueDate != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              LineIcons.clock,
                              size: 12,
                              color: theme.hintColor.withAlpha(204), // 0.8 * 255
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDate(widget.task.dueDate!),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.hintColor.withAlpha(204), // 0.8 * 255
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                
                // Drag handle
                Icon(
                  LineIcons.gripLines,
                  color: theme.hintColor.withAlphaValue(0.5),
                ),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.1, end: 0, duration: 300.ms, curve: Curves.easeOutQuart),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(DateTime(now.year, now.month, now.day));
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Tomorrow';
    } else if (difference.inDays == -1) {
      return 'Yesterday';
    } else if (difference.inDays < 7 && difference.inDays > -7) {
      return '${difference.inDays.abs()} days ${difference.inDays > 0 ? 'left' : 'ago'}';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

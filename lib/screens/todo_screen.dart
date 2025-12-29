import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import '../blocs/todo/todo_bloc.dart';

class TodoScreen extends StatelessWidget {
  const TodoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      body: Column(
        children: [
          /// 🔹 HEADER ROW
          Padding(
            padding: const EdgeInsets.only(top: 8, right: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Your Tasks",
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
                
                /// 🔽 SORT / FILTER BUTTON (Updated)
                BlocBuilder<TodoBloc, TodoState>(
                  builder: (context, state) {
                    // Default values
                    var currentSort = TodoSortOption.newest;
                    var currentFilter = TodoFilterStatus.all;

                    // Get values from state
                    if (state is TodosLoaded) {
                      currentSort = state.sortOption;
                      currentFilter = state.filterStatus;
                    }

                    return PopupMenuButton<dynamic>(
                      icon: const Icon(Icons.sort, color: AppTheme.textSecondary),
                      onSelected: (value) {
                        if (value is TodoSortOption) {
                          context.read<TodoBloc>().add(TodoSortChanged(value));
                        } else if (value is TodoFilterStatus) {
                          context.read<TodoBloc>().add(TodoFilterChanged(value));
                        }
                      },
                      itemBuilder: (context) => [
                         const PopupMenuItem(enabled: false, child: Text("SORT BY", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                         CheckedPopupMenuItem(
                           value: TodoSortOption.newest,
                           checked: currentSort == TodoSortOption.newest,
                           child: const Text("Newest"),
                         ),
                         CheckedPopupMenuItem(
                           value: TodoSortOption.aToZ,
                           checked: currentSort == TodoSortOption.aToZ,
                           child: const Text("A-Z"),
                         ),
                         
                         const PopupMenuDivider(),
                         
                         const PopupMenuItem(enabled: false, child: Text("FILTER", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                         CheckedPopupMenuItem(
                           value: TodoFilterStatus.all,
                           checked: currentFilter == TodoFilterStatus.all,
                           child: const Text("All"),
                         ),
                         CheckedPopupMenuItem(
                           value: TodoFilterStatus.pending,
                           checked: currentFilter == TodoFilterStatus.pending,
                           child: const Text("Pending"),
                         ),
                         CheckedPopupMenuItem(
                           value: TodoFilterStatus.completed,
                           checked: currentFilter == TodoFilterStatus.completed,
                           child: const Text("Completed"),
                         ),
                      ],
                    );
                  },
                ),

                /// ➕ ADD BUTTON
                TextButton.icon(
                  onPressed: () => _addTodoDialog(context),
                  icon: const Icon(Icons.add, color: Colors.red),
                  label: Text("Add",
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      )),
                ),
              ],
            ),
          ),

          /// 🔍 SEARCH BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.cardWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (val) {
                  context.read<TodoBloc>().add(TodoSearchChanged(val));
                },
                decoration: InputDecoration(
                  hintText: "Search tasks...",
                  hintStyle: GoogleFonts.inter(color: AppTheme.textSecondary),
                  prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),
          ),

          /// 📋 LIST VIEW
          Flexible(
            child: BlocBuilder<TodoBloc, TodoState>(
              builder: (context, state) {
                if (state is TodosLoading || state is TodosInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is TodosError) {
                  return Center(child: Text(state.message));
                }

                // USE FILTERED LIST
                final todos = (state as TodosLoaded).filteredTodos;

                if (todos.isEmpty) {
                  return const Center(child: Text("No tasks found"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: todos.length,
                  itemBuilder: (context, index) {
                    final todo = todos[index];
                    final data = todo.data() as Map<String, dynamic>;

                    return Dismissible(
                      key: Key(todo.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.accentRed,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) {
                        context.read<TodoBloc>().add(TodoDeleteRequested(todo.id));
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.cardWhite,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            Checkbox(
                              value: data['isDone'] ?? false,
                              activeColor: AppTheme.accentGreen,
                              onChanged: (val) {
                                context
                                    .read<TodoBloc>()
                                    .add(TodoToggleRequested(todo.id, val!));
                              },
                            ),
                            Expanded(
                              child: Text(
                                data['title'] ?? '',
                                style: GoogleFonts.inter(
                                  fontSize: 15,
                                  color: (data['isDone'] ?? false)
                                      ? AppTheme.textSecondary
                                      : AppTheme.textPrimary,
                                  decoration: (data['isDone'] ?? false)
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addTodoDialog(BuildContext context) {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Task"),
        content: TextField(controller: controller),
        actions: [
          TextButton(
            onPressed: () {
              context.read<TodoBloc>().add(TodoAddRequested(controller.text));
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}
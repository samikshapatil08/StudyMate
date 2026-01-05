import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../theme.dart';
import '../blocs/todo/todo_bloc.dart';

class TodoScreen extends StatefulWidget {
  const TodoScreen({super.key});

  @override
  State<TodoScreen> createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            children: [
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
                          color: theme.textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    BlocBuilder<TodoBloc, TodoState>(
                      builder: (context, state) {
                        bool isCalendar = false;
                        if (state is TodosLoaded) {
                          isCalendar = state.isCalendarView;
                          return IconButton(
                            icon: Icon(
                              isCalendar
                                  ? Icons.list_alt
                                  : Icons.calendar_month,
                              color: AppTheme.primaryPurple,
                            ),
                            onPressed: () =>
                                context.read<TodoBloc>().add(TodoViewToggled()),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    BlocBuilder<TodoBloc, TodoState>(
                      builder: (context, state) {
                        var currentSort = TodoSortOption.newest;
                        var currentFilter = TodoFilterStatus.all;
                        if (state is TodosLoaded) {
                          currentSort = state.sortOption;
                          currentFilter = state.filterStatus;
                        }

                        return PopupMenuButton<dynamic>(
                          icon: Icon(Icons.sort, color: theme.iconTheme.color),
                          color: theme.cardColor,
                          onSelected: (value) {
                            if (value is TodoSortOption) {
                              context
                                  .read<TodoBloc>()
                                  .add(TodoSortChanged(value));
                            } else if (value is TodoFilterStatus) {
                              context
                                  .read<TodoBloc>()
                                  .add(TodoFilterChanged(value));
                            }
                          },
                          itemBuilder: (context) => [
                            CheckedPopupMenuItem(
                                value: TodoSortOption.urgency,
                                checked: currentSort == TodoSortOption.urgency,
                                child: const Text("Urgency")),
                            CheckedPopupMenuItem(
                                value: TodoSortOption.newest,
                                checked: currentSort == TodoSortOption.newest,
                                child: const Text("Newest")),
                            CheckedPopupMenuItem(
                                value: TodoSortOption.aToZ,
                                checked: currentSort == TodoSortOption.aToZ,
                                child: const Text("A-Z")),
                            const PopupMenuDivider(),
                            CheckedPopupMenuItem(
                                value: TodoFilterStatus.all,
                                checked: currentFilter == TodoFilterStatus.all,
                                child: const Text("All")),
                            CheckedPopupMenuItem(
                                value: TodoFilterStatus.pending,
                                checked:
                                    currentFilter == TodoFilterStatus.pending,
                                child: const Text("Pending")),
                            CheckedPopupMenuItem(
                                value: TodoFilterStatus.completed,
                                checked:
                                    currentFilter == TodoFilterStatus.completed,
                                child: const Text("Completed")),
                          ],
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle,
                          color: AppTheme.primaryPurple, size: 28),
                      onPressed: () => _addTodoDialog(context),
                    ),
                  ],
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                    onChanged: (val) =>
                        context.read<TodoBloc>().add(TodoSearchChanged(val)),
                    decoration: InputDecoration(
                      hintText: "Search tasks...",
                      hintStyle: GoogleFonts.inter(
                          color: theme.textTheme.bodyMedium?.color),
                      prefixIcon: Icon(Icons.search,
                          color: theme.textTheme.bodyMedium?.color),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<TodoBloc, TodoState>(
                  builder: (context, state) {
                    if (state is TodosLoading || state is TodosInitial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is TodosError) {
                      return Center(
                          child: Text(state.message,
                              style: TextStyle(
                                  color: theme.textTheme.bodyLarge?.color)));
                    }

                    final loadedState = state as TodosLoaded;
                    final allFilteredTodos = loadedState.filteredTodos;
                    final isCalendarView = loadedState.isCalendarView;

                    if (isCalendarView) {
                      return _buildCalendarView(allFilteredTodos, theme);
                    }

                    if (allFilteredTodos.isEmpty) {
                      return Center(
                          child: Text("No tasks found",
                              style: TextStyle(
                                  color: theme.textTheme.bodyMedium?.color)));
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: allFilteredTodos.length,
                      itemBuilder: (context, index) =>
                          _buildTodoItem(allFilteredTodos[index], theme),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodoItem(QueryDocumentSnapshot todo, ThemeData theme) {
    final data = todo.data() as Map<String, dynamic>;
    DateTime? deadline;
    if (data['deadline'] != null) {
      deadline = (data['deadline'] as Timestamp).toDate();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Slidable(
        key: Key(todo.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (context) =>
                  context.read<TodoBloc>().add(TodoDeleteRequested(todo.id)),
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              icon: Icons.delete,
              label: 'Delete',
              borderRadius: BorderRadius.circular(12),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
              color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Checkbox(
              value: data['isDone'] ?? false,
              activeColor: AppTheme.primaryPurple,
              onChanged: (val) => context
                  .read<TodoBloc>()
                  .add(TodoToggleRequested(todo.id, val ?? false)),
            ),
            title: Text(
              data['title'] ?? '',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: (data['isDone'] ?? false)
                    ? theme.textTheme.bodyMedium?.color
                    : theme.textTheme.bodyLarge?.color,
                decoration: (data['isDone'] ?? false)
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            subtitle: deadline != null
                ? Text(
                    "Due: ${_formatDate(deadline)}",
                    style: TextStyle(
                      color: deadline.isBefore(DateTime.now()) &&
                              !(data['isDone'] ?? false)
                          ? Colors.red
                          : Colors.grey,
                      fontSize: 12,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarView(
      List<QueryDocumentSnapshot> todos, ThemeData theme) {
    final selectedDayTasks =
        _getEventsForDay(todos, _selectedDay ?? DateTime.now());
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: theme.cardColor, borderRadius: BorderRadius.circular(16)),
          child: TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            eventLoader: (day) => _getEventsForDay(todos, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() => _calendarFormat = format);
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: CalendarStyle(
              defaultTextStyle:
                  TextStyle(color: theme.textTheme.bodyLarge?.color),
              weekendTextStyle:
                  TextStyle(color: theme.textTheme.bodyLarge?.color),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle:
                  TextStyle(color: theme.textTheme.bodyLarge?.color),
              leftChevronIcon:
                  Icon(Icons.chevron_left, color: theme.iconTheme.color),
              rightChevronIcon:
                  Icon(Icons.chevron_right, color: theme.iconTheme.color),
            ),
          ),
        ),
        const SizedBox(height: 10),
        if (_selectedDay != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text("Tasks for ${_formatDate(_selectedDay!)}",
                  style: GoogleFonts.inter(
                      fontWeight: FontWeight.bold, color: Colors.grey)),
            ),
          ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: selectedDayTasks.length,
            itemBuilder: (context, index) =>
                _buildTodoItem(selectedDayTasks[index], theme),
          ),
        ),
      ],
    );
  }

  List<QueryDocumentSnapshot> _getEventsForDay(
      List<QueryDocumentSnapshot> allTodos, DateTime day) {
    return allTodos.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['deadline'] == null) return false;
      return isSameDay((data['deadline'] as Timestamp).toDate(), day);
    }).toList();
  }

  String _formatDate(DateTime date) => "${date.day}/${date.month}/${date.year}";

  void _addTodoDialog(BuildContext context) {
    final controller = TextEditingController();
    DateTime? selectedDate;
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("New Task",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.bodyLarge?.color)),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                            controller: controller,
                            decoration:
                                const InputDecoration(labelText: "Task Name")),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            TextButton(
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() => selectedDate = picked);
                                }
                              },
                              child: Text(
                                selectedDate == null
                                    ? "Set Deadline"
                                    : "Due: ${_formatDate(selectedDate!)}",
                                style: TextStyle(
                                    color: selectedDate == null
                                        ? Colors.blue
                                        : Colors.green),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel")),
                TextButton(
                  onPressed: () {
                    context.read<TodoBloc>().add(TodoAddRequested(
                        controller.text,
                        deadline: selectedDate));
                    Navigator.pop(context);
                  },
                  child: const Text("Add"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

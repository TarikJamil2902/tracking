import 'package:flutter/material.dart';
import 'package:flutter_app_test/models/notification.dart';
import '../widgets/app_drawer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<NotificationItem> allNotifications = [
    NotificationItem(
      title: 'Late Arrival',
      message: 'Rahul arrived 10 minutes late today.',
      date: DateTime.now().subtract(Duration(hours: 2)),
      type: 'attendance',
    ),
    NotificationItem(
      title: 'Exam Date',
      message: 'Annual exams will start from March 25.',
      date: DateTime.now().subtract(Duration(days: 1)),
      type: 'event',
      isPriority: true,
    ),
    NotificationItem(
      title: 'Results Published',
      message: '2nd Term results are now available.',
      date: DateTime.now().subtract(Duration(days: 3)),
      type: 'academic',
    ),
    NotificationItem(
      title: 'Fee Payment Reminder',
      message: 'April fees are pending.',
      date: DateTime.now().subtract(Duration(days: 5)),
      type: 'administrative',
      isPriority: true,
    ),
  ];

  String filter = 'All';
  DateTimeRange? selectedDateRange;

  List<NotificationItem> get filteredNotifications {
    List<NotificationItem> list = List.from(allNotifications);

    if (filter == 'Read') {
      list = list.where((n) => n.isRead).toList();
    } else if (filter == 'Unread') {
      list = list.where((n) => !n.isRead).toList();
    }

    if (selectedDateRange != null) {
      list = list
          .where(
            (n) =>
                n.date.isAfter(
                  selectedDateRange!.start.subtract(Duration(days: 1)),
                ) &&
                n.date.isBefore(
                  selectedDateRange!.end.add(Duration(days: 1)),
                ),
          )
          .toList();
    }

    list.sort((a, b) {
      if (a.isPriority != b.isPriority) {
        return b.isPriority ? 1 : -1;
      }
      return b.date.compareTo(a.date);
    });

    return list;
  }

  void toggleRead(NotificationItem item) {
    setState(() {
      item.isRead = !item.isRead;
    });
  }

  void pickDateRange() async {
    DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024),
      lastDate: DateTime.now().add(Duration(days: 30)),
    );
    if (picked != null) {
      setState(() {
        selectedDateRange = picked;
      });
    }
  }

  void clearDateFilter() {
    setState(() {
      selectedDateRange = null;
    });
  }

  void deleteNotification(NotificationItem item) {
    setState(() {
      allNotifications.remove(item);
    });
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'attendance':
        return Icons.access_time;
      case 'event':
        return Icons.event;
      case 'academic':
        return Icons.school;
      case 'administrative':
        return Icons.admin_panel_settings;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Notifications'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) => setState(() => filter = val),
            itemBuilder: (context) => [
              PopupMenuItem(value: 'All', child: Text('All')),
              PopupMenuItem(value: 'Read', child: Text('Read')),
              PopupMenuItem(value: 'Unread', child: Text('Unread')),
            ],
            icon: Icon(Icons.filter_list),
          ),
          IconButton(onPressed: pickDateRange, icon: Icon(Icons.date_range)),
          if (selectedDateRange != null)
            IconButton(onPressed: clearDateFilter, icon: Icon(Icons.clear)),
        ],
      ),
      drawer: const AppDrawer(),
      body: ListView.builder(
        itemCount: filteredNotifications.length,
        itemBuilder: (context, index) {
          final item = filteredNotifications[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: item.isPriority ? Colors.red : Colors.blue,
                child: Icon(_getIcon(item.type), color: Colors.white),
              ),
              title: Text(
                item.title,
                style: TextStyle(
                  fontWeight: item.isRead ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.message),
                  const SizedBox(height: 4),
                  Text(
                    item.date.toString(),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'mark') {
                    toggleRead(item);
                  } else if (value == 'delete') {
                    deleteNotification(item);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'mark',
                    child: Text(item.isRead ? 'Mark as Unread' : 'Mark as Read'),
                  ),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

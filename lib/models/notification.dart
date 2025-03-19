class NotificationItem {
  final String title;
  final String message;
  final DateTime date;
  final String type; // attendance, event, academic, administrative
  bool isRead;
  final bool isPriority;

  NotificationItem({
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    this.isRead = false,
    this.isPriority = false,
  });
}

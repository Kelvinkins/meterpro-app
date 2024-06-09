import 'package:flutter/material.dart';
import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/services/transaction_service.dart';

class NotificationListPage extends StatefulWidget {
  final String userId;

  const NotificationListPage(this.userId, {Key? key}) : super(key: key);

  @override
  _NotificationListPageState createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  List<dynamic> notifications = [];
  bool _isLoading = false;
  final TransactoinService transactionService = TransactoinService();

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() => _isLoading = true);
    final data = await transactionService.getMyNotifications(context, widget.userId);
    setState(() {
      notifications = data;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
      ),
      body: _isLoading
          ? Center(child: Spinners.spinkitFadingCircle)
          : notifications.isNotEmpty
          ? _buildNotificationList()
          : Center(child: Text("No Notifications")),
    );
  }

  Widget _buildNotificationList() {
    return ListView.builder(
      itemCount: notifications.length,
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return Card(
          child: ListTile(
            title: Text('Message: ${notification["message"]}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Date & Time: ${notification["dateTime"]}'),
                Text('Notification Type: ${_getNotificationTypeString(notification["notificationType"])}'),
              ],
            ),
            onTap: () {},
          ),
        );
      },
    );
  }

  String _getNotificationTypeString(int notificationType) {
    switch (notificationType) {
      case 0:
        return 'Vending';
      case 1:
        return 'System';
      case 2:
        return 'AI';
      case 3:
        return 'Others';
      default:
        return 'Unknown';
    }
  }
}

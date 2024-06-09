import 'package:flutter/material.dart';
import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/services/transaction_service.dart';

class SubscriptionHistoryScreen extends StatefulWidget {
  final String meterSn;

  const SubscriptionHistoryScreen({required this.meterSn, Key? key}) : super(key: key);

  @override
  _SubscriptionHistoryScreenState createState() => _SubscriptionHistoryScreenState();
}

class _SubscriptionHistoryScreenState extends State<SubscriptionHistoryScreen> {
  List<dynamic> transactions = [];
  bool _isLoading = false;
  final TransactoinService transactionService = TransactoinService();

  @override
  void initState() {
    super.initState();
    _fetchTransactionHistory();
  }

  Future<void> _fetchTransactionHistory() async {
    setState(() => _isLoading = true);
    final subscriptions = await transactionService.getSubscriptionHistory(context, widget.meterSn);
    setState(() {
      transactions = subscriptions;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Subscription History'),
      ),
      body: _isLoading
          ? Center(child: Spinners.spinkitFadingCircle)
          : transactions.isNotEmpty
          ? _buildTransactionList()
          : Center(child: Text("No Subscription History")),
    );
  }

  Widget _buildTransactionList() {
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Card(
          child: ListTile(
            title: Text('Subscription Value: ${transaction["subscriptionValue"]} unit(s)'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Balance: ${transaction["balance"]}'),
                Text('Date Activated: ${transaction["dateActivated"]}'),
              ],
            ),
            onTap: () {},
          ),
        );
      },
    );
  }
}

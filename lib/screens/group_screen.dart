import 'package:flutter/material.dart';
import 'package:meterpro/common/loaders.dart';
import 'package:meterpro/services/transaction_service.dart';
import 'package:meterpro/widgets/meter_dashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'create_meter_group_form.dart';
import 'meters_by_group.dart';
import 'package:meterpro/services/transaction_service.dart';


class GroupScreen extends StatefulWidget {
  const GroupScreen({Key? key}) : super(key: key);

  @override
  _GroupScreenState createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  final TransactoinService transactionService = TransactoinService();
  bool isLoading = true;
  List<dynamic> groups = [];

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  void fetchGroups() async {
    try {
      var userEmail = FirebaseAuth.instance.currentUser?.email ?? '';
      var fetchedGroups = await transactionService.getGroups(context, userEmail);
      setState(() {
        groups = fetchedGroups;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print('Failed to fetch groups: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Meter Groups'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => CreateMeterGroupForm())).whenComplete(() {
            fetchGroups();

          });
        },
        label: Text("Add Group"),
        icon: Icon(Icons.add),
      ),
      body: isLoading
          ? Center(child: Spinners.spinkitFadingCircle)
          : groups.isEmpty
          ? Center(child: Text("No groups found"))
          : buildGroupList(),
    );
  }

  Widget buildGroupList() {
    return ListView.builder(
      itemCount: groups.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(groups[index]['groupName']),
          subtitle: Text('${groups[index]['count']} meters'),
          trailing: Text(groups[index]['dateTime'].toString()),
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => MeterByGroupScreen(groups[index]),
            ));
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:infibo_app/components/index.dart';
import 'package:infibo_app/pages/main/logic.dart';

final MainLogic _logic = MainLogic();
class ChoseUsersPage extends StatefulWidget {
  const ChoseUsersPage({super.key});

  @override
  State<ChoseUsersPage> createState() => _ChoseUsersPageState();
}

class _ChoseUsersPageState extends State<ChoseUsersPage> {
  @override
  Widget build(BuildContext context) {
    return _buildHeader();  
  }
}
  Widget _buildHeader() {
    return Positioned(
      left: 20,
      top: 55,
      right: 44,
      child: AppTopHeader(timeText: _logic.timeText, dateText: _logic.dateText),
    );
  }

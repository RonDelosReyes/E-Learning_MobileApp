import 'package:flutter/material.dart';
import '../widget/student/hamburg_menu_stud.dart';

class ARLabPage extends StatefulWidget {
  const ARLabPage({super.key});

  @override
  State<ARLabPage> createState() => _ARLabPageState();
}

class _ARLabPageState extends State<ARLabPage> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F2FD),
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            'AR Lab',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          backgroundColor: const Color(0xFF33A1E0),
        ),
        drawer: const AppDrawer(),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'AR Lab is not available at the moment',
          style: TextStyle(fontSize: 16, color: Colors.black54),
        ),
      ),
    );
  }
}
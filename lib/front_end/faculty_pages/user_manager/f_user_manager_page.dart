import 'package:flutter/material.dart';
import '../../../back_end/services/pages/faculty/user_manager/user_manager_service.dart';
import '../../widgets/hamburgMenu.dart';

class FacultyUserManagerPage extends StatefulWidget {
  const FacultyUserManagerPage({super.key});

  @override
  State<FacultyUserManagerPage> createState() => _FacultyUserManagerPageState();
}

class _FacultyUserManagerPageState extends State<FacultyUserManagerPage> {
  final UserService _userService = UserService();

  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  List<String> _statusList = [];
  bool _isStatusLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatuses();
  }

  Future<void> _loadStatuses() async {
    try {
      final statuses = await _userService.fetchStatusList();
      setState(() {
        _statusList = statuses;
        _isStatusLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading statuses: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        Navigator.of(context).pushReplacementNamed('/faculty_dashboard');
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F9FF),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF1565C0), size: 30),
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search user...',
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Color(0xFF90CAF9)),
                  ),
                  style: const TextStyle(color: Color(0xFF1565C0), fontSize: 18),
                  onChanged: (val) => setState(() {}),
                )
              : const Text(
                  'USER MANAGER',
                  style: TextStyle(
                    color: Color(0xFF1565C0),
                    fontSize: 20,
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = !_isSearching;
                  if (!_isSearching) _searchController.clear();
                });
              },
            ),
          ],
        ),
        drawer: const AppDrawer(currentRoute: 'user_manager'),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _userService.fetchAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            }

            final allUsers = snapshot.data ?? [];
            final filteredUsers = allUsers.where((u) {
              final name = u['full_name'].toString().toLowerCase();
              final query = _searchController.text.toLowerCase();
              return name.contains(query);
            }).toList();

            if (filteredUsers.isEmpty) {
              return const Center(child: Text("No users found."));
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                final user = filteredUsers[index];
                return _buildUserCard(user);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final String status = user['status'];
    final String role = user['role'];
    final int userId = user['user_id'];

    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = Colors.green;
        break;
      case 'inactive':
        statusColor = Colors.orange;
        break;
      case 'pending':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFE3F2FD),
            child: Text(
              user['full_name'][0].toUpperCase(),
              style: const TextStyle(color: Color(0xFF1565C0), fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user['full_name'],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
                Text(
                  role,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          _isStatusLoading
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : _buildStatusDropdown(userId, status, statusColor),
        ],
      ),
    );
  }

  Widget _buildStatusDropdown(int userId, String currentStatus, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: currentStatus,
          icon: Icon(Icons.arrow_drop_down, color: color, size: 20),
          style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          onChanged: (newStatus) {
            if (newStatus != null && newStatus != currentStatus) {
              _userService.updateStudentStatus(userId, newStatus, context).then((_) {
                setState(() {}); // Refresh list
              });
            }
          },
          items: _statusList.map((s) {
            return DropdownMenuItem<String>(
              value: s,
              child: Text(s),
            );
          }).toList(),
        ),
      ),
    );
  }
}

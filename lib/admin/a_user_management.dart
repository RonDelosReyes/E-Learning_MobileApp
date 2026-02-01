import 'package:e_learning_app/widget/admin/hamburg_menu_main.dart';
import 'package:flutter/material.dart';
import '../services/admin/admin_user_manager.dart';

class AdminUserManagerPage extends StatefulWidget {
  const AdminUserManagerPage({super.key});

  @override
  State<AdminUserManagerPage> createState() => _AdminUserManagerPageState();
}

class _AdminUserManagerPageState extends State<AdminUserManagerPage> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'all';
  List<String> _statusList = [];
  bool _isStatusLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStatusOptions();
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  Future<void> _fetchStatusOptions() async {
    _statusList = await AdminUserManagerBackend.fetchStatusList();
    setState(() => _isStatusLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: const Color(0xFFE3F2FD),
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: const Color(0xFF33A1E0),
          iconTheme: const IconThemeData(color: Colors.white, size: 30),
          title: _isSearching
              ? TextField(
            controller: _searchController,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Search users...",
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
            ),
            onChanged: (value) => setState(() {}),
          )
              : const Text(
            'User Management',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
          actions: [
            _isSearching
                ? IconButton(icon: const Icon(Icons.close, color: Colors.white),
                onPressed: _stopSearch)
                : IconButton(
                icon: const Icon(Icons.search, color: Colors.white),
                onPressed: _startSearch),
          ],
        ),
        drawer: AdminAppDrawer(),
        body: _isStatusLoading
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<List<Map<String, dynamic>>>(
          future: AdminUserManagerBackend.fetchAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text(
                    "No users found.",
                    style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
                  ));
            }

            final users = snapshot.data!;
            final filteredUsers = users.where((user) {
              if (_selectedFilter == 'all') return true;
              return user['status'].toLowerCase() == _selectedFilter;
            }).toList();

            return Column(
              children: [
                // Filter Dropdown
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Text(
                        "Filter Status: ",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight
                            .bold),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _selectedFilter,
                        items: AdminUserManagerBackend.filterOptions
                            .map((f) =>
                            DropdownMenuItem(
                                value: f['value'], child: Text(f['display']!)))
                            .toList(),
                        onChanged: (newValue) {
                          if (newValue == null) return;
                          setState(() => _selectedFilter = newValue);
                        },
                      ),
                    ],
                  ),
                ),
                // User List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      String dropdownValue = _statusList.contains(
                          user['status'])
                          ? user['status']
                          : _statusList.first;

                      return Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          title: Text(
                            "${user['full_name']}",
                            style: const TextStyle(fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Role: ${user['role']}"),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text("Status: "),
                                  StatefulBuilder(
                                    builder: (context, setDropdownState) {
                                      return DropdownButton<String>(
                                        value: dropdownValue,
                                        items: _statusList
                                            .map((status) =>
                                            DropdownMenuItem(value: status,
                                                child: Text(status)))
                                            .toList(),
                                        onChanged: (newStatus) async {
                                          if (newStatus == null) return;

                                          await AdminUserManagerBackend
                                              .updateUserStatus(
                                              user['user_id'], newStatus,
                                              user['role'], context);

                                          setDropdownState(() =>
                                          dropdownValue = newStatus);
                                          user['status'] = newStatus;
                                        },
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
import 'package:e_learning_app/widget/faculty/hamburg_menu_facul.dart';
import 'package:flutter/material.dart';
import '../services/faculty/faculty_user_manager.dart';

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

  String _selectedFilter = 'all';
  final List<Map<String, String>> _filterOptions = [
    {'display': 'All', 'value': 'all'},
    {'display': 'Active', 'value': 'active'},
    {'display': 'Inactive', 'value': 'inactive'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchStatusList();
  }

  void _startSearch() => setState(() => _isSearching = true);

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
  }

  Future<void> _fetchStatusList() async {
    try {
      final statuses = await _userService.fetchStatusList();
      setState(() {
        _statusList = statuses;
        _isStatusLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching statuses: $e');
      setState(() => _isStatusLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> _fetchUsersWithStatus() async {
    return await _userService.fetchAllUsers();
  }

  Future<void> _updateStudentStatus(int userId, String newStatus,
      BuildContext context) async {
    await _userService.updateStudentStatus(userId, newStatus, context);
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
            onChanged: (value) =>
                debugPrint("Searching for user: $value"),
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
                ? IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _stopSearch,
            )
                : IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: _startSearch,
            ),
          ],
        ),
        drawer: FacultyAppDrawer(),
        body: _isStatusLoading
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchUsersWithStatus(),
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
                ),
              );
            }

            final users = snapshot.data!;
            final filteredUsers = users.where((user) {
              if (_selectedFilter == 'all') return true;
              return user['status'].toLowerCase() == _selectedFilter;
            }).toList();

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Text(
                        "Filter Status: ",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      DropdownButton<String>(
                        value: _selectedFilter,
                        items: _filterOptions
                            .map((f) =>
                            DropdownMenuItem(
                              value: f['value'],
                              child: Text(f['display']!),
                            ))
                            .toList(),
                        onChanged: (newValue) {
                          if (newValue == null) return;
                          setState(() {
                            _selectedFilter = newValue;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final user = filteredUsers[index];
                      final isStudent = user['role'] == 'Student';
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
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Role: ${user['role']}"),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Text("Status: "),
                                  if (isStudent)
                                    StatefulBuilder(
                                      builder:
                                          (context, setDropdownState) {
                                        return DropdownButton<String>(
                                          value: dropdownValue,
                                          items: _statusList
                                              .map((status) =>
                                              DropdownMenuItem(
                                                value: status,
                                                child: Text(status),
                                              ))
                                              .toList(),
                                          onChanged: (newStatus) async {
                                            if (newStatus == null) return;

                                            await _updateStudentStatus(
                                                user['user_id'],
                                                newStatus,
                                                context);

                                            setDropdownState(() {
                                              dropdownValue = newStatus;
                                            });
                                            user['status'] = newStatus;
                                          },
                                        );
                                      },
                                    )
                                  else
                                    Text(
                                      user['status'],
                                      style: TextStyle(
                                        color: user['status']
                                            .toLowerCase() ==
                                            'active'
                                            ? Colors.green
                                            : Colors.red,
                                      ),
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
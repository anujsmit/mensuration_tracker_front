import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/providers/user_provider.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ScrollController _horizontalScrollController = ScrollController();
  String _searchQuery = '';
  bool? _verificationFilter;
  bool _isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUsers(reset: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _horizontalScrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMoreUsers();
    }
  }

  Future<void> _loadUsers({required bool reset}) async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (reset) {
      userProvider.reset();
    }

    try {
      await userProvider.fetchUsers(
        token: authProvider.token!,
        search: _searchQuery,
        verified: _verificationFilter,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading users: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _loadMoreUsers() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    if (_isLoadingMore ||
        userProvider.isLoading ||
        userProvider.currentPage >= userProvider.totalPages) {
      return;
    }

    setState(() => _isLoadingMore = true);

    try {
      await userProvider.fetchUsers(
        token: authProvider.token!,
        page: userProvider.currentPage + 1,
        search: _searchQuery,
        verified: _verificationFilter,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading more users: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingMore = false);
      }
    }
  }

  Future<void> _onRefresh() async {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _verificationFilter = null;
    });
    await _loadUsers(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'User Management (${userProvider.totalUsers})',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        backgroundColor: colorScheme.primary,
        elevation: 4,
        automaticallyImplyLeading: false, // Remove back button
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                // Search and Filter Bar
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                  color: colorScheme.surface,
                  child: isSmallScreen
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                  hintText: 'Search users...',
                                  prefixIcon: Icon(Icons.search,
                                      color: colorScheme.primary),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 16),
                                ),
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: isSmallScreen ? 14 : 16,
                                ),
                                onChanged: (value) {
                                  setState(() => _searchQuery = value);
                                  _loadUsers(reset: true);
                                },
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildFilterDropdown(theme, colorScheme),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _searchController,
                                  decoration: InputDecoration(
                                    hintText: 'Search by name, email, username...',
                                    prefixIcon: Icon(Icons.search,
                                        color: colorScheme.primary),
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 16, horizontal: 16),
                                  ),
                                  style: theme.textTheme.bodyLarge,
                                  onChanged: (value) {
                                    setState(() => _searchQuery = value);
                                    _loadUsers(reset: true);
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            _buildFilterDropdown(theme, colorScheme),
                          ],
                        ),
                ),

                // User Table
                Expanded(
                  child: _buildUserList(userProvider, theme, constraints),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildFilterDropdown(ThemeData theme, ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<bool?>(
          value: _verificationFilter,
          icon: Icon(Icons.filter_list, color: colorScheme.primary),
          borderRadius: BorderRadius.circular(12),
          dropdownColor: colorScheme.surface,
          items: [
            DropdownMenuItem<bool?>(
              value: null,
              child: Text('All Users', style: theme.textTheme.bodyLarge),
            ),
            DropdownMenuItem<bool?>(
              value: true,
              child: Text('Verified Only', style: theme.textTheme.bodyLarge),
            ),
            DropdownMenuItem<bool?>(
              value: false,
              child: Text('Unverified Only', style: theme.textTheme.bodyLarge),
            ),
          ],
          onChanged: (value) {
            setState(() => _verificationFilter = value);
            _loadUsers(reset: true);
          },
        ),
      ),
    );
  }

  Widget _buildUserList(
      UserProvider userProvider, ThemeData theme, BoxConstraints constraints) {
    final colorScheme = theme.colorScheme;
    final isSmallScreen = constraints.maxWidth < 600;

    if (userProvider.isLoading && userProvider.users.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      );
    }

    if (userProvider.error != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
          child: Card(
            color: colorScheme.error.withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: ${userProvider.error}',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: colorScheme.error,
                  fontSize: isSmallScreen ? 14 : 16,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (userProvider.users.isEmpty) {
      return Center(
        child: Card(
          color: colorScheme.surface,
          margin: EdgeInsets.all(isSmallScreen ? 8 : 16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No users found',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ),
      );
    }

    // Sort users by ID in ascending order
    final sortedUsers = List<UserModel>.from(userProvider.users)
      ..sort((a, b) => a.id.compareTo(b.id));

    return Column(
      children: [
        // Horizontal scrollable table container
        Expanded(
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Container(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 16),
              child: SingleChildScrollView(
                controller: _horizontalScrollController,
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minWidth: constraints.maxWidth,
                  ),
                  child: _buildUsersTable(context, sortedUsers, userProvider, constraints),
                ),
              ),
            ),
          ),
        ),
        
        // Loading and end indicators
        if (_isLoadingMore)
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
            child: Center(child: CircularProgressIndicator()),
          ),
        if (userProvider.currentPage >= userProvider.totalPages &&
            userProvider.users.isNotEmpty)
          Padding(
            padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
            child: Center(
              child: Text(
                'No more users to load',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                  fontSize: isSmallScreen ? 12 : 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUsersTable(
    BuildContext context,
    List<UserModel> users,
    UserProvider provider,
    BoxConstraints constraints,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dateFormat = DateFormat('MMM d, yyyy');
    final isSmallScreen = constraints.maxWidth < 600;

    // Calculate column widths based on screen size
    final columnWidths = {
      0: isSmallScreen ? 50.0 : 80.0, // ID
      1: isSmallScreen ? 120.0 : 180.0, // Name
      2: isSmallScreen ? 150.0 : 220.0, // Email
      3: isSmallScreen ? 100.0 : 120.0, // Status
      4: isSmallScreen ? 80.0 : 100.0, // Role
      5: isSmallScreen ? 100.0 : 120.0, // Created At
      6: isSmallScreen ? 100.0 : 120.0, // Actions
    };

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: isSmallScreen ? 4 : 8),
      child: Theme(
        data: theme.copyWith(
          cardTheme: CardThemeData(
            color: colorScheme.surface,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        child: DataTable(
          columnSpacing: isSmallScreen ? 8 : 16,
          headingRowHeight: isSmallScreen ? 48 : 56,
          dataRowHeight: isSmallScreen ? 56 : 64,
          headingRowColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) =>
                colorScheme.primary.withOpacity(0.05),
          ),
          dataRowColor: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.hovered)) {
                return colorScheme.primary.withOpacity(0.08);
              }
              return null;
            },
          ),
          columns: [
            DataColumn(
              label: SizedBox(
                width: columnWidths[0],
                child: Text('ID',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: isSmallScreen ? 12 : 16,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: columnWidths[1],
                child: Text('Name',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: isSmallScreen ? 12 : 16,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: columnWidths[2],
                child: Text('Email',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: isSmallScreen ? 12 : 16,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: columnWidths[3],
                child: Text('Status',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: isSmallScreen ? 12 : 16,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: columnWidths[4],
                child: Text('Role',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: isSmallScreen ? 12 : 16,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: columnWidths[5],
                child: Text('Created At',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: isSmallScreen ? 12 : 16,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
            DataColumn(
              label: SizedBox(
                width: columnWidths[6],
                child: Text('Actions',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontSize: isSmallScreen ? 12 : 16,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            ),
          ],
          rows: users.map((user) {
            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: columnWidths[0],
                    child: Text(
                      user.id.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: columnWidths[1],
                    child: Text(
                      user.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: columnWidths[2],
                    child: Text(
                      user.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: columnWidths[3],
                    child: Chip(
                      label: Text(
                        user.verified ? 'Verified' : 'Unverified',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: user.verified
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      backgroundColor: user.verified
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: columnWidths[4],
                    child: Chip(
                      label: Text(
                        user.isAdmin ? 'Admin' : 'User',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: user.isAdmin
                              ? Colors.blue.shade700
                              : Colors.grey.shade700,
                          fontSize: isSmallScreen ? 10 : 12,
                        ),
                      ),
                      backgroundColor: user.isAdmin
                          ? Colors.blue.shade50
                          : Colors.grey.shade100,
                      padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 12, vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: columnWidths[5],
                    child: Text(
                      dateFormat.format(user.createdAt),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  SizedBox(
                    width: columnWidths[6],
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit,
                              size: isSmallScreen ? 16 : 20,
                              color: colorScheme.secondary),
                          onPressed: () =>
                              _showEditUserDialog(context, provider, user),
                          tooltip: 'Edit User',
                        ),
                        IconButton(
                          icon: Icon(Icons.delete,
                              size: isSmallScreen ? 16 : 20,
                              color: colorScheme.error),
                          onPressed: () =>
                              _confirmDelete(context, provider, user),
                          tooltip: 'Delete User',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showEditUserDialog(
    BuildContext context,
    UserProvider provider,
    UserModel user,
  ) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final usernameController = TextEditingController(text: user.username);
    bool isAdmin = user.isAdmin;
    bool isVerified = user.verified;
    bool _isUpdating = false;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          return AlertDialog(
            backgroundColor: colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'Edit User',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontSize: isSmallScreen ? 18 : 20,
              ),
            ),
            content: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: isSmallScreen ? double.infinity : 400,
                ),
                child: Card(
                  color: colorScheme.surface,
                  elevation: 0,
                  child: Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 8.0 : 16.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_isUpdating)
                            LinearProgressIndicator(
                              color: colorScheme.primary,
                              backgroundColor:
                                  colorScheme.primary.withOpacity(0.3),
                            ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: 'Name',
                            ),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: emailController,
                            decoration: const InputDecoration(
                              labelText: 'Email',
                            ),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email is required';
                              }
                              if (!value.contains('@')) {
                                return 'Enter a valid email';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: usernameController,
                            decoration: const InputDecoration(
                              labelText: 'Username',
                            ),
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Username is required';
                              }
                              if (value.length < 3) {
                                return 'Username must be at least 3 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          CheckboxListTile(
                            title: Text('Is Admin',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: isSmallScreen ? 14 : 16,
                                )),
                            value: isAdmin,
                            onChanged: (val) => setState(() => isAdmin = val!),
                            activeColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            tileColor: colorScheme.surface,
                          ),
                          CheckboxListTile(
                            title: Text('Is Verified',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontSize: isSmallScreen ? 14 : 16,
                                )),
                            value: isVerified,
                            onChanged: (val) => setState(() => isVerified = val!),
                            activeColor: colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            tileColor: colorScheme.surface,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isUpdating ? null : () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.onSurface,
                ),
                child: Text(
                  'Cancel',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 16 : 24,
                      vertical: isSmallScreen ? 8 : 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _isUpdating
                    ? null
                    : () async {
                        if (formKey.currentState?.validate() ?? false) {
                          setState(() => _isUpdating = true);
                          final updatedUser = UserModel(
                            id: user.id,
                            name: nameController.text.trim(),
                            email: emailController.text.trim(),
                            username: usernameController.text.trim(),
                            verified: isVerified,
                            isAdmin: isAdmin,
                            createdAt: user.createdAt,
                            lastLogin: user.lastLogin,
                          );

                          try {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            await provider.updateUser(
                              updatedUser,
                              authProvider.token!,
                            );
                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('User updated successfully'),
                                  backgroundColor: Colors.green.shade600,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                              _loadUsers(reset: true);
                            }
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Update failed: ${e.toString()}'),
                                  backgroundColor: colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          }
                        }
                      },
                child: Text(
                  'Save',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontSize: isSmallScreen ? 14 : 16,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDelete(
    BuildContext context,
    UserProvider provider,
    UserModel user,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirm Deletion',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: isSmallScreen ? 18 : 20,
          ),
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: isSmallScreen ? double.infinity : 400,
          ),
          child: Text(
            'Are you sure you want to delete user: ${user.name}?',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: isSmallScreen ? 14 : 16,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.onSurface,
            ),
            child: Text(
              'Cancel',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await provider.deleteUser(user.id, authProvider.token!);
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('User deleted successfully'),
                      backgroundColor: Colors.green.shade600,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                  _loadUsers(reset: true);
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Deletion failed: ${e.toString()}'),
                      backgroundColor: colorScheme.error,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  );
                }
              }
            },
            child: Text(
              'Delete',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.error,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
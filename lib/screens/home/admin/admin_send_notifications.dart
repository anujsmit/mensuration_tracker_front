import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:mensurationhealthapp/providers/admin_notification_provider.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/providers/user_provider.dart';

class AdminSendNotifications extends StatefulWidget {
  const AdminSendNotifications({super.key});

  @override
  State<AdminSendNotifications> createState() => _AdminSendNotificationsState();
}

class _AdminSendNotificationsState extends State<AdminSendNotifications> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  int _selectedType = 3;
  bool _isSending = false;
  bool _sendToAll = true;
  String? _error;
  List<String> _selectedUserIds = [];
  List<UserModel> _availableUsers = [];
  bool _isLoadingUsers = false;

  final Map<int, String> _notificationTypes = {
    1: 'System Alert',
    2: 'Health Tip',
    3: 'Admin Message',
    4: 'Reminder',
  };

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    if (_isLoadingUsers) return;
    
    setState(() => _isLoadingUsers = true);
    
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      await userProvider.fetchUsers(token: authProvider.token!);
      setState(() => _availableUsers = userProvider.users);
    } catch (e) {
      setState(() => _error = 'Failed to load users: ${e.toString()}');
    } finally {
      setState(() => _isLoadingUsers = false);
    }
  }

  Future<void> _sendNotification() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSending = true;
      _error = null;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final notificationProvider = Provider.of<AdminNotificationProvider>(context, listen: false);

      Map<String, dynamic> result;
      
      if (_sendToAll) {
        result = await notificationProvider.sendNotificationToAll(
          token: authProvider.token!,
          title: _titleController.text,
          message: _messageController.text,
          typeId: _selectedType,
        );
      } else if (_selectedUserIds.isNotEmpty) {
        result = await notificationProvider.sendNotification(
          token: authProvider.token!,
          title: _titleController.text,
          message: _messageController.text,
          typeId: _selectedType,
          userIds: _selectedUserIds,
        );
      } else {
        setState(() => _error = 'Please select at least one user');
        return;
      }

      if (mounted) {
        _showSuccessDialog(
          title: _titleController.text,
          message: _messageController.text,
          type: _notificationTypes[_selectedType]!,
          recipients: _sendToAll ? 'All users' : '${_selectedUserIds.length} selected users',
        );
        _resetForm();
      }
    } on http.ClientException catch (e) {
      _handleError('Network error: ${e.message}');
    } on FormatException catch (e) {
      _handleError('Data format error: ${e.message}');
    } on Exception catch (e) {
      _handleError('Failed to send: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  void _resetForm() {
    _titleController.clear();
    _messageController.clear();
    setState(() => _selectedUserIds = []);
  }

  void _handleError(String error) {
    if (mounted) {
      setState(() => _error = error);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          duration: const Duration(seconds: 4),
        ),
      );
      debugPrint('Notification error: $error');
    }
  }

  void _showSuccessDialog({
    required String title,
    required String message,
    required String type,
    required String recipients,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Notification Sent',
          style: theme.textTheme.titleLarge,
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _DetailRow(label: 'Title', value: title),
              _DetailRow(label: 'Type', value: type),
              _DetailRow(label: 'Recipients', value: recipients),
              const SizedBox(height: 16),
              Text(
                'Message:',
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                message,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleUserSelection(String userId) {
    setState(() {
      _selectedUserIds.contains(userId)
          ? _selectedUserIds.remove(userId)
          : _selectedUserIds.add(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (_error != null) 
                _ErrorDisplay(error: _error!, colorScheme: colorScheme),
              const SizedBox(height: 16),
              _NotificationTitleField(controller: _titleController),
              const SizedBox(height: 16),
              _NotificationMessageField(controller: _messageController),
              const SizedBox(height: 16),
              _NotificationTypeDropdown(
                selectedType: _selectedType,
                notificationTypes: _notificationTypes,
                onChanged: (value) => setState(() => _selectedType = value!),
              ),
              const SizedBox(height: 16),
              _RecipientSelector(
                sendToAll: _sendToAll,
                onChanged: (value) => setState(() => _sendToAll = value),
                isLoadingUsers: _isLoadingUsers,
                availableUsers: _availableUsers,
                selectedUserIds: _selectedUserIds,
                onUserSelected: _toggleUserSelection,
                colorScheme: colorScheme,
              ),
              const Spacer(),
              _SendButton(
                isSending: _isSending,
                onPressed: _sendNotification,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGuidelines() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: colorScheme.surface,
        title: Text(
          'Notification Guidelines',
          style: theme.textTheme.titleLarge,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GuidelineItem(
              icon: Icons.title,
              text: 'Titles should be concise (max 100 chars)',
              colorScheme: colorScheme,
            ),
            _GuidelineItem(
              icon: Icons.message,
              text: 'Messages should be clear (max 500 chars)',
              colorScheme: colorScheme,
            ),
            _GuidelineItem(
              icon: Icons.category,
              text: 'Select appropriate notification type',
              colorScheme: colorScheme,
            ),
            _GuidelineItem(
              icon: Icons.warning,
              text: 'System Alerts are high priority',
              colorScheme: colorScheme,
            ),
            _GuidelineItem(
              icon: Icons.health_and_safety,
              text: 'Health Tips provide useful information',
              colorScheme: colorScheme,
            ),
            _GuidelineItem(
              icon: Icons.timer,
              text: 'Reminders should include time-sensitive info',
              colorScheme: colorScheme,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'GOT IT',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorDisplay extends StatelessWidget {
  final String error;
  final ColorScheme colorScheme;

  const _ErrorDisplay({required this.error, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationTitleField extends StatelessWidget {
  final TextEditingController controller;

  const _NotificationTitleField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Title*',
        prefixIcon: Icon(Icons.title, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
      maxLength: 100,
      style: theme.textTheme.bodyLarge,
    );
  }
}

class _NotificationMessageField extends StatelessWidget {
  final TextEditingController controller;

  const _NotificationMessageField({required this.controller});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: 'Message*',
        prefixIcon: Icon(Icons.message, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        alignLabelWithHint: true,
      ),
      validator: (value) => value?.isEmpty ?? true ? 'Please enter a message' : null,
      maxLength: 500,
      maxLines: 5,
      minLines: 3,
      style: theme.textTheme.bodyLarge,
    );
  }
}

class _NotificationTypeDropdown extends StatelessWidget {
  final int selectedType;
  final Map<int, String> notificationTypes;
  final ValueChanged<int?> onChanged;

  const _NotificationTypeDropdown({
    required this.selectedType,
    required this.notificationTypes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonFormField<int>(
      value: selectedType,
      decoration: InputDecoration(
        labelText: 'Type*',
        prefixIcon: Icon(Icons.category, color: theme.colorScheme.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      items: notificationTypes.entries.map((entry) => DropdownMenuItem(
        value: entry.key,
        child: Text(entry.value),
      )).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select a type' : null,
      style: theme.textTheme.bodyLarge,
    );
  }
}

class _RecipientSelector extends StatelessWidget {
  final bool sendToAll;
  final ValueChanged<bool> onChanged;
  final bool isLoadingUsers;
  final List<UserModel> availableUsers;
  final List<String> selectedUserIds;
  final Function(String) onUserSelected;
  final ColorScheme colorScheme;

  const _RecipientSelector({
    required this.sendToAll,
    required this.onChanged,
    required this.isLoadingUsers,
    required this.availableUsers,
    required this.selectedUserIds,
    required this.onUserSelected,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Card(
          elevation: 2,
          color: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: SwitchListTile(
            title: Text(
              'Send to all users',
              style: theme.textTheme.bodyLarge,
            ),
            value: sendToAll,
            onChanged: onChanged,
            secondary: Icon(
              Icons.group,
              color: colorScheme.primary,
            ),
          ),
        ),
        if (!sendToAll) ...[
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Select Recipients',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  isLoadingUsers
                      ? Center(
                          child: CircularProgressIndicator(
                            color: colorScheme.primary,
                          ),
                        )
                      : availableUsers.isEmpty
                          ? Text(
                              'No users available',
                              style: theme.textTheme.bodyMedium,
                            )
                          : Column(
                              children: [
                                SizedBox(
                                  height: 200,
                                  child: ListView.builder(
                                    itemCount: availableUsers.length,
                                    itemBuilder: (context, index) {
                                      final user = availableUsers[index];
                                      return ListTile(
                                        leading: Checkbox(
                                          value: selectedUserIds.contains(user.id.toString()),
                                          onChanged: (_) => onUserSelected(user.id.toString()),
                                          activeColor: colorScheme.primary,
                                        ),
                                        title: Text(
                                          user.name,
                                          style: theme.textTheme.bodyLarge,
                                        ),
                                        subtitle: Text(
                                          user.email,
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        trailing: CircleAvatar(
                                          backgroundColor: colorScheme.primaryContainer,
                                          child: Text(
                                            user.name[0],
                                            style: TextStyle(
                                              color: colorScheme.onPrimaryContainer,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Text(
                                  '${selectedUserIds.length} selected',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ],
                            ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _SendButton extends StatelessWidget {
  final bool isSending;
  final VoidCallback onPressed;

  const _SendButton({required this.isSending, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isSending ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSending
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onPrimary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_active),
                  const SizedBox(width: 8),
                  Text(
                    'SEND NOTIFICATION',
                    style: theme.textTheme.labelLarge,
                  ),
                ],
              ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuidelineItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final ColorScheme colorScheme;

  const _GuidelineItem({
    required this.icon,
    required this.text,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
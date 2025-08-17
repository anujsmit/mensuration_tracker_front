import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mensurationhealthapp/providers/auth_provider.dart';
import 'package:mensurationhealthapp/providers/notification_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final _scrollController = ScrollController();
  bool _isInitialLoad = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData(true));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !context.read<UserNotificationProvider>().isLoading) {
      _loadMore();
    }
  }

  Future<void> _loadData(bool refresh) async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuth && authProvider.token != null) {
      await context
          .read<UserNotificationProvider>()
          .fetchNotifications(authProvider.token, refresh: refresh);
    }
    if (mounted) {
      setState(() => _isInitialLoad = false);
    }
  }

  Future<void> _loadMore() async {
    final authProvider = context.read<AuthProvider>();
    if (authProvider.isAuth && authProvider.token != null) {
      await context
          .read<UserNotificationProvider>()
          .fetchNotifications(authProvider.token);
    }
  }

  Future<void> _markAllAsRead(
    AuthProvider auth,
    UserNotificationProvider notifications,
  ) async {
    if (auth.token == null) return;
    try {
      await notifications.markAllAsRead(auth.token!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('All notifications marked as read.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notifications = context.watch<UserNotificationProvider>();
    final theme = Theme.of(context);
    final bool hasUnread = notifications.unreadCount > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
        actions: [
          if (auth.isAuth && hasUnread)
            IconButton(
              icon: Badge(
                label: Text(
                  notifications.unreadCount.toString(),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: theme.colorScheme.secondary,
                child: Icon(
                  Icons.mark_chat_read_outlined,
                  color: theme.colorScheme.onPrimary,
                ),
              ),
              onPressed: () => _markAllAsRead(auth, notifications),
              tooltip: 'Mark all as read',
            ),
          if (auth.isAuth)
            IconButton(
              icon: Icon(
                Icons.refresh,
                color: theme.colorScheme.onPrimary,
              ),
              onPressed: () => _loadData(true),
              tooltip: 'Refresh',
            ),
        ],
      ),
      body: !auth.isAuth
          ? _buildAuthRequiredView(theme)
          : _buildBody(notifications, theme),
    );
  }

  Widget _buildBody(UserNotificationProvider provider, ThemeData theme) {
    if (_isInitialLoad && provider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: theme.colorScheme.secondary,
        ),
      );
    }
    if (provider.error.isNotEmpty) {
      return _buildErrorView(provider, theme);
    }
    if (provider.notifications.isEmpty) {
      return _buildEmptyView(theme);
    }
    return _buildNotificationList(provider, theme);
  }

  Widget _buildNotificationList(
    UserNotificationProvider provider,
    ThemeData theme,
  ) {
    return RefreshIndicator(
      color: theme.colorScheme.secondary,
      onRefresh: () => _loadData(true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: provider.notifications.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == provider.notifications.length) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.secondary,
                ),
              ),
            );
          }
          final notification = provider.notifications[index];
          return _buildNotificationCard(notification, provider, theme);
        },
      ),
    );
  }

  Widget _buildNotificationCard(
    NotificationItem notification,
    UserNotificationProvider provider,
    ThemeData theme,
  ) {
    final auth = context.read<AuthProvider>();
    final bool isRead = notification.isRead;
    final Color cardColor = isRead
        ? theme.cardColor.withOpacity(0.6)
        : theme.cardColor;
    final Color borderColor = isRead
        ? theme.colorScheme.surface.withOpacity(0.3)
        : notification.color.withOpacity(0.6);

    return Card(
      elevation: isRead ? 1 : 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: borderColor,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      color: cardColor,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          if (!isRead && auth.token != null) {
            try {
              await provider.markAsRead(notification.id, auth.token!);
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to mark as read: ${e.toString()}'),
                    backgroundColor: theme.colorScheme.error,
                  ),
                );
              }
            }
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: notification.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  notification.iconData,
                  color: notification.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                        color: isRead
                            ? theme.textTheme.bodyLarge?.color?.withOpacity(0.8)
                            : theme.textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodyMedium?.color
                            ?.withOpacity(isRead ? 0.7 : 0.9),
                      ),
                    ),
                    if (notification.senderName != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'From: ${notification.senderName}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: theme.textTheme.bodySmall?.color
                                ?.withOpacity(0.6),
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      notification.formatTimeAgo(),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthRequiredView(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.login,
              size: 64,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: 24),
            Text(
              'Login Required',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Please sign in to view your notifications.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
              ),
              child: Text(
                'Sign In',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(UserNotificationProvider provider, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'An Error Occurred',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              provider.error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.tonal(
              onPressed: () => _loadData(true),
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary.withOpacity(0.2),
              ),
              child: Text(
                'Try Again',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyView(ThemeData theme) {
    return RefreshIndicator(
      color: theme.colorScheme.secondary,
      onRefresh: () => _loadData(true),
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off_outlined,
                    size: 64,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'All Caught Up!',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'You have no new notifications at the moment.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// 1. In lib/features/home/screens/main_screen.dart:
// - Define 'globalNotificationListenerProvider' (or remove reference if unused)
// - Ensure ProfileScreen constructor uses named argument 'required String username'
// - Fix const expression errors in MainScreen (remove const from non-const widgets)

// 2. In lib/features/auth/screens/register_screen.dart:
// - Ensure authServiceProvider is correctly defined and imported.

// 3. In lib/features/chat/screens/chat_list_screen.dart:
// - Check currentUser data structure. It seems p.username is String but currentUser['username'] might be dynamic.
// - Use int.tryParse(currentUser['username']?.toString() ?? '') if needed or verify type.

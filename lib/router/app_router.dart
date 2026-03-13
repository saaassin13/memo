import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/todo/todo_screen.dart';
import '../presentation/screens/calendar/calendar_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/features/memo/memo_list_screen.dart';
import '../presentation/screens/features/memo/memo_edit_screen.dart';
import '../presentation/screens/features/diary/diary_screen.dart';
import '../presentation/screens/features/countdown/countdown_screen.dart';
import '../presentation/screens/features/account/account_screen.dart';
import '../presentation/screens/features/goal/goal_screen.dart';
import '../presentation/screens/features/weight/weight_screen.dart';
import '../presentation/widgets/main_scaffold.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainScaffold(navigationShell: navigationShell);
        },
        branches: [
          // 应用 Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
              GoRoute(
                path: '/memo',
                builder: (context, state) => const MemoListScreen(),
              ),
              GoRoute(
                path: '/memo/edit',
                builder: (context, state) {
                  final idStr = state.uri.queryParameters['id'];
                  final category = state.uri.queryParameters['category'];
                  final id = idStr != null ? int.tryParse(idStr) : null;
                  return MemoEditScreen(memoId: id, initialCategory: category);
                },
              ),
              GoRoute(
                path: '/diary',
                builder: (context, state) => const DiaryScreen(),
              ),
              GoRoute(
                path: '/countdown',
                builder: (context, state) => const CountdownScreen(),
              ),
              GoRoute(
                path: '/account',
                builder: (context, state) => const AccountScreen(),
              ),
              GoRoute(
                path: '/goal',
                builder: (context, state) => const GoalScreen(),
              ),
              GoRoute(
                path: '/weight',
                builder: (context, state) => const WeightScreen(),
              ),
            ],
          ),
          // Todo Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/todo',
                builder: (context, state) => const TodoScreen(),
              ),
            ],
          ),
          // 日历 Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/calendar',
                builder: (context, state) => const CalendarScreen(),
              ),
            ],
          ),
          // 我的 Tab
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

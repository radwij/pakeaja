import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pakeaja/screens/add_item_screen.dart';
import 'package:pakeaja/screens/currently_renting_screen.dart';
import 'package:pakeaja/screens/item_detail_screen.dart';
import 'package:pakeaja/screens/rented_out_screen.dart';
import 'package:pakeaja/screens/user_listing_screen.dart';
import 'package:pakeaja/screens/user_profile_screen.dart';
import '/screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'widgets/app_bottom_navigation_bar.dart';

class AppRouter {
  final GoRouter router = GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null &&
          state.matchedLocation != '/login' &&
          state.matchedLocation != '/register') {
        return '/login';
      }
      if (user != null &&
          (state.matchedLocation == '/login' ||
              state.matchedLocation == '/register')) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          int selectedIndex = 0;
          if (state.matchedLocation == '/home') selectedIndex = 0;
          if (state.matchedLocation == '/add-item') selectedIndex = 1;
          if (state.matchedLocation == '/profile') selectedIndex = 2;
          return Scaffold(
            body: child,
            bottomNavigationBar: AppBottomNavigationBar(
              selectedIndex: selectedIndex,
            ),
          );
        },
        routes: [
          GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/add-item',
            builder: (context, state) => const AddItemScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/item/:id',
            builder: (context, state) {
              final itemId = state.pathParameters['id']!;
              return ItemDetailScreen(itemId: itemId);
            },
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: '/user-profile',
            builder: (context, state) => const UserProfileScreen(),
          ),
          GoRoute(
            path: '/user-listing',
            builder: (context, state) => const UserListingScreen(),
          ),
          GoRoute(
            path: '/rented-out',
            builder: (context, state) => const RentedOutScreen(),
          ),
          GoRoute(
            path: '/currently-renting',
            builder: (context, state) => const CurrentlyRentingScreen(),
          ),
        ],
      ),
    ],
  );
}

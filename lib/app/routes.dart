import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/enums.dart';
import '../providers/auth_provider.dart';
import '../screens/adopter/adopter_dashboard_screen.dart';
import '../screens/adopter/adopter_history_screen.dart';
import '../screens/adopter/adopter_requests_screen.dart';
import '../screens/adopter/favorites_screen.dart';
import '../screens/about_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/find_pets_screen.dart';
import '../screens/home_screen.dart';
import '../screens/how_it_works_screen.dart';
import '../screens/map/map_screen.dart';
import '../screens/owner/add_edit_pet_screen.dart';
import '../screens/owner/add_edit_store_screen.dart';
import '../screens/owner/my_pets_screen.dart';
import '../screens/owner/owner_dashboard_screen.dart';
import '../screens/owner/owner_requests_screen.dart';
import '../screens/owner/owner_stores_screen.dart';
import '../screens/pet_details_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/stores/store_details_screen.dart';
import '../screens/stores/stores_screen.dart';

/// Whisker World Router Configuration with Role-Based Route Guarding
class AppRoutes {
  AppRoutes._();

  // Public Routes
  static const String home = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String pets = '/pets';
  static const String petDetails = '/pets/:id';
  static const String stores = '/stores';
  static const String storeDetails = '/stores/:id';
  static const String map = '/map';
  static const String about = '/about';
  static const String howItWorks = '/how-it-works';

  // Common Protected Routes
  static const String profile = '/profile';

  // Pet Owner Routes
  static const String ownerDashboard = '/owner/dashboard';
  static const String ownerPets = '/owner/pets';
  static const String ownerPetsAdd = '/owner/pets/add';
  static const String ownerPetsEdit = '/owner/pets/:id/edit';
  static const String ownerStore = '/owner/store';
  static const String ownerStores = '/owner/stores';
  static const String ownerStoresCreate = '/owner/stores/create';
  static const String ownerStoresEdit = '/owner/stores/:id/edit';
  static const String ownerRequests = '/owner/requests';

  // Pet Adopter Routes
  static const String adopterDashboard = '/adopter/dashboard';
  static const String adopterRequests = '/adopter/requests';
  static const String adopterHistory = '/adopter/history';
  static const String favorites = '/favorites';

  /// Creates a GoRouter instance bound to [AuthProvider] for reactive route guarding
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: home,
      refreshListenable: authProvider,
      redirect: (BuildContext context, GoRouterState state) {
        final isAuthenticated = authProvider.isAuthenticated;
        final role = authProvider.userRole;
        final path = state.matchedLocation;

        final isAuthRoute = path == login || path == register;
        final isOwnerRoute = path.startsWith('/owner');
        final isAdopterRoute = path.startsWith('/adopter') || path == favorites;
        final isProfileRoute = path == profile;

        // 1. Unauthenticated users cannot access protected routes
        if (!isAuthenticated && (isOwnerRoute || isAdopterRoute || isProfileRoute)) {
          return login;
        }

        // 2. Authenticated users on /login or /register get redirected to their dashboard
        if (isAuthenticated && isAuthRoute) {
          return role == UserRole.petOwner ? ownerDashboard : adopterDashboard;
        }

        // 3. Role segregation:
        // Pet Adopter cannot access /owner/* routes
        if (isAuthenticated && isOwnerRoute && role != UserRole.petOwner) {
          return adopterDashboard;
        }

        // Pet Owner cannot access /adopter/* routes
        if (isAuthenticated && isAdopterRoute && role != UserRole.petAdopter) {
          return ownerDashboard;
        }

        return null; // Proceed as requested
      },
      routes: [
        // Public
        GoRoute(
          path: home,
          builder: (context, state) {
            final scrollTo = state.uri.queryParameters['scrollTo'] ?? state.uri.queryParameters['section'];
            return HomeScreen(scrollToSection: scrollTo);
          },
        ),
        GoRoute(
          path: login,
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: pets,
          builder: (context, state) => const FindPetsScreen(),
        ),
        GoRoute(
          path: petDetails,
          builder: (context, state) {
            final petId = state.pathParameters['id'] ?? '';
            return PetDetailsScreen(id: petId);
          },
        ),
        GoRoute(
          path: stores,
          builder: (context, state) => const StoresScreen(),
        ),
        GoRoute(
          path: storeDetails,
          builder: (context, state) {
            final storeId = state.pathParameters['id'] ?? '';
            return StoreDetailsScreen(storeId: storeId);
          },
        ),
        GoRoute(
          path: map,
          builder: (context, state) {
            final petId = state.uri.queryParameters['petId'];
            return MapScreen(initialPetId: petId);
          },
        ),
        GoRoute(
          path: about,
          builder: (context, state) => const AboutScreen(),
        ),
        GoRoute(
          path: howItWorks,
          builder: (context, state) => const HowItWorksScreen(),
        ),

        // Shared Protected
        GoRoute(
          path: profile,
          builder: (context, state) => const ProfileScreen(),
        ),

        // Pet Owner Protected Routes
        GoRoute(
          path: ownerDashboard,
          builder: (context, state) => const OwnerDashboardScreen(),
        ),
        GoRoute(
          path: ownerPets,
          builder: (context, state) => const MyPetsScreen(),
        ),
        GoRoute(
          path: ownerPetsAdd,
          builder: (context, state) => const AddEditPetScreen(),
        ),
        GoRoute(
          path: ownerPetsEdit,
          builder: (context, state) {
            final petId = state.pathParameters['id'];
            return AddEditPetScreen(petId: petId);
          },
        ),
        GoRoute(
          path: ownerStore,
          builder: (context, state) => const OwnerStoresScreen(),
        ),
        GoRoute(
          path: ownerStores,
          builder: (context, state) => const OwnerStoresScreen(),
        ),
        GoRoute(
          path: ownerStoresCreate,
          builder: (context, state) => const AddEditStoreScreen(),
        ),
        GoRoute(
          path: ownerStoresEdit,
          builder: (context, state) {
            final storeId = state.pathParameters['id'];
            return AddEditStoreScreen(storeId: storeId);
          },
        ),
        GoRoute(
          path: ownerRequests,
          builder: (context, state) => const OwnerRequestsScreen(),
        ),

        // Pet Adopter Protected Routes
        GoRoute(
          path: adopterDashboard,
          builder: (context, state) => const AdopterDashboardScreen(),
        ),
        GoRoute(
          path: adopterRequests,
          builder: (context, state) => const AdopterRequestsScreen(),
        ),
        GoRoute(
          path: adopterHistory,
          builder: (context, state) => const AdopterHistoryScreen(),
        ),
        GoRoute(
          path: favorites,
          builder: (context, state) => const FavoritesScreen(),
        ),
      ],
    );
  }
}
